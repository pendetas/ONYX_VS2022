using System;
using System.Collections.Generic;
using System.Configuration;
using Npgsql;
using ONYX_DDAC.Helpers;
using ONYX_DDAC.Models;

namespace ONYX_DDAC.DAL
{
    public class AuthRateLimitRepository
    {
        public AuthRateLimitResult Check(string action, string identifier, string ipAddress, DateTime nowUtc)
        {
            AuthRateLimitResult account = CheckKey(action, BuildIdentityKey("account", identifier), nowUtc);
            AuthRateLimitResult ip = CheckKey(action, BuildIdentityKey("ip", ipAddress), nowUtc);

            if (account.IsBlocked && ip.IsBlocked)
                return account.BlockedUntil >= ip.BlockedUntil ? account : ip;

            return account.IsBlocked ? account : ip;
        }

        public AuthRateLimitResult RecordFailure(
            string action,
            string identifier,
            string ipAddress,
            int maxAttempts,
            TimeSpan window,
            TimeSpan blockDuration,
            DateTime nowUtc)
        {
            var results = new List<AuthRateLimitResult>
            {
                RecordFailureForKey(action, BuildIdentityKey("account", identifier), maxAttempts, window, blockDuration, nowUtc),
                RecordFailureForKey(action, BuildIdentityKey("ip", ipAddress), maxAttempts, window, blockDuration, nowUtc)
            };

            AuthRateLimitResult blocked = null;
            foreach (AuthRateLimitResult result in results)
            {
                if (!result.IsBlocked)
                    continue;

                if (blocked == null || result.BlockedUntil > blocked.BlockedUntil)
                    blocked = result;
            }

            return blocked ?? results[0];
        }

        public AuthRateLimitResult ConsumeAttempt(
            string action,
            string identityKey,
            int maxAttempts,
            TimeSpan window,
            TimeSpan blockDuration,
            DateTime nowUtc)
        {
            return RecordFailureForKey(
                action,
                BuildSingleIdentityKey(identityKey),
                maxAttempts,
                window,
                blockDuration,
                nowUtc);
        }

        public void Reset(string action, string identifier, string ipAddress)
        {
            using (var conn = new NpgsqlConnection(GetConnectionString("DefaultConnection")))
            {
                conn.Open();
                using (var cmd = new NpgsqlCommand(@"
                    DELETE FROM auth_rate_limits
                    WHERE action = @Action
                      AND identity_key IN (@AccountKey, @IpKey)", conn))
                {
                    cmd.Parameters.AddWithValue("@Action", NormalizeAction(action));
                    cmd.Parameters.AddWithValue("@AccountKey", BuildIdentityKey("account", identifier));
                    cmd.Parameters.AddWithValue("@IpKey", BuildIdentityKey("ip", ipAddress));
                    cmd.ExecuteNonQuery();
                }
            }
        }

        public void Reset(string action, string identityKey)
        {
            using (var conn = new NpgsqlConnection(GetConnectionString("DefaultConnection")))
            {
                conn.Open();
                using (var cmd = new NpgsqlCommand(@"
                    DELETE FROM auth_rate_limits
                    WHERE action = @Action AND identity_key = @IdentityKey", conn))
                {
                    cmd.Parameters.AddWithValue("@Action", NormalizeAction(action));
                    cmd.Parameters.AddWithValue("@IdentityKey", BuildSingleIdentityKey(identityKey));
                    cmd.ExecuteNonQuery();
                }
            }
        }

        public int CleanupExpiredWindows(DateTime nowUtc, TimeSpan retention)
        {
            using (var conn = new NpgsqlConnection(GetConnectionString("DefaultConnection")))
            {
                conn.Open();
                using (var cmd = new NpgsqlCommand(@"
                    DELETE FROM auth_rate_limits
                    WHERE last_attempt_at < @Cutoff
                      AND (blocked_until IS NULL OR blocked_until < @NowUtc)", conn))
                {
                    cmd.Parameters.AddWithValue("@Cutoff", nowUtc.Subtract(retention));
                    cmd.Parameters.AddWithValue("@NowUtc", nowUtc);
                    return cmd.ExecuteNonQuery();
                }
            }
        }

        private AuthRateLimitResult CheckKey(string action, string identityKey, DateTime nowUtc)
        {
            AuthRateLimit rateLimit = Get(action, identityKey);
            if (rateLimit == null || rateLimit.BlockedUntil == null || rateLimit.BlockedUntil <= nowUtc)
                return AuthRateLimitResult.Allow(0);

            return new AuthRateLimitResult
            {
                IsBlocked = true,
                BlockedUntil = rateLimit.BlockedUntil,
                AttemptCount = rateLimit.AttemptCount,
                AttemptsRemaining = 0
            };
        }

        private AuthRateLimitResult RecordFailureForKey(
            string action,
            string identityKey,
            int maxAttempts,
            TimeSpan window,
            TimeSpan blockDuration,
            DateTime nowUtc)
        {
            string normalizedAction = NormalizeAction(action);

            using (var conn = new NpgsqlConnection(GetConnectionString("DefaultConnection")))
            {
                conn.Open();
                using (var tx = conn.BeginTransaction())
                {
                    AcquireIdentityLock(normalizedAction, identityKey, conn, tx);
                    AuthRateLimit existing = Get(normalizedAction, identityKey, conn, tx);

                    int attemptCount;
                    DateTime windowStartedAt;
                    DateTime? blockedUntil;

                    if (existing == null ||
                        existing.WindowStartedAt <= nowUtc.Subtract(window) ||
                        (existing.BlockedUntil.HasValue && existing.BlockedUntil.Value <= nowUtc))
                    {
                        attemptCount = 1;
                        windowStartedAt = nowUtc;
                        blockedUntil = null;

                        if (existing == null)
                            Insert(normalizedAction, identityKey, attemptCount, windowStartedAt, blockedUntil, nowUtc, conn, tx);
                        else
                            Update(existing.Id, attemptCount, windowStartedAt, blockedUntil, nowUtc, conn, tx);
                    }
                    else
                    {
                        attemptCount = existing.AttemptCount + 1;
                        windowStartedAt = existing.WindowStartedAt;
                        blockedUntil = existing.BlockedUntil > nowUtc
                            ? existing.BlockedUntil
                            : (attemptCount > maxAttempts ? nowUtc.Add(blockDuration) : (DateTime?)null);

                        Update(existing.Id, attemptCount, windowStartedAt, blockedUntil, nowUtc, conn, tx);
                    }

                    tx.Commit();

                    return new AuthRateLimitResult
                    {
                        IsBlocked = blockedUntil > nowUtc,
                        BlockedUntil = blockedUntil,
                        AttemptCount = attemptCount,
                        AttemptsRemaining = Math.Max(0, maxAttempts - attemptCount)
                    };
                }
            }
        }

        private AuthRateLimit Get(string action, string identityKey)
        {
            using (var conn = new NpgsqlConnection(GetConnectionString("DefaultConnection")))
            {
                conn.Open();
                return Get(action, identityKey, conn, null);
            }
        }

        private AuthRateLimit Get(string action, string identityKey, NpgsqlConnection conn, NpgsqlTransaction tx)
        {
            string sql = @"
                SELECT id, action, identity_key, attempt_count, window_started_at, blocked_until, last_attempt_at
                FROM auth_rate_limits
                WHERE action = @Action AND identity_key = @IdentityKey";

            if (tx != null)
                sql += " FOR UPDATE";

            using (var cmd = new NpgsqlCommand(sql, conn, tx))
            {
                cmd.Parameters.AddWithValue("@Action", NormalizeAction(action));
                cmd.Parameters.AddWithValue("@IdentityKey", identityKey);

                using (var reader = cmd.ExecuteReader())
                {
                    return reader.Read()
                        ? new AuthRateLimit
                        {
                            Id = reader.GetInt64(0),
                            Action = reader.GetString(1),
                            IdentityKey = reader.GetString(2),
                            AttemptCount = reader.GetInt32(3),
                            WindowStartedAt = reader.GetDateTime(4),
                            BlockedUntil = reader.IsDBNull(5) ? (DateTime?)null : reader.GetDateTime(5),
                            LastAttemptAt = reader.GetDateTime(6)
                        }
                        : null;
                }
            }
        }

        private static void AcquireIdentityLock(
            string action,
            string identityKey,
            NpgsqlConnection conn,
            NpgsqlTransaction tx)
        {
            using (var cmd = new NpgsqlCommand(@"
                SELECT pg_advisory_xact_lock(
                    hashtext(@Action),
                    hashtext(@IdentityKey))", conn, tx))
            {
                cmd.Parameters.AddWithValue("@Action", action);
                cmd.Parameters.AddWithValue("@IdentityKey", identityKey);
                cmd.ExecuteNonQuery();
            }
        }

        private static void Insert(
            string action,
            string identityKey,
            int attemptCount,
            DateTime windowStartedAt,
            DateTime? blockedUntil,
            DateTime nowUtc,
            NpgsqlConnection conn,
            NpgsqlTransaction tx)
        {
            using (var cmd = new NpgsqlCommand(@"
                INSERT INTO auth_rate_limits
                    (action, identity_key, attempt_count, window_started_at, blocked_until, last_attempt_at)
                VALUES
                    (@Action, @IdentityKey, @AttemptCount, @WindowStartedAt, @BlockedUntil, @LastAttemptAt)", conn, tx))
            {
                AddWriteParameters(cmd, action, identityKey, attemptCount, windowStartedAt, blockedUntil, nowUtc);
                cmd.ExecuteNonQuery();
            }
        }

        private static void Update(
            long id,
            int attemptCount,
            DateTime windowStartedAt,
            DateTime? blockedUntil,
            DateTime nowUtc,
            NpgsqlConnection conn,
            NpgsqlTransaction tx)
        {
            using (var cmd = new NpgsqlCommand(@"
                UPDATE auth_rate_limits
                SET attempt_count = @AttemptCount,
                    window_started_at = @WindowStartedAt,
                    blocked_until = @BlockedUntil,
                    last_attempt_at = @LastAttemptAt
                WHERE id = @Id", conn, tx))
            {
                cmd.Parameters.AddWithValue("@Id", id);
                cmd.Parameters.AddWithValue("@AttemptCount", attemptCount);
                cmd.Parameters.AddWithValue("@WindowStartedAt", windowStartedAt);
                cmd.Parameters.AddWithValue("@BlockedUntil", (object)blockedUntil ?? DBNull.Value);
                cmd.Parameters.AddWithValue("@LastAttemptAt", nowUtc);
                cmd.ExecuteNonQuery();
            }
        }

        private static void AddWriteParameters(
            NpgsqlCommand cmd,
            string action,
            string identityKey,
            int attemptCount,
            DateTime windowStartedAt,
            DateTime? blockedUntil,
            DateTime nowUtc)
        {
            cmd.Parameters.AddWithValue("@Action", action);
            cmd.Parameters.AddWithValue("@IdentityKey", identityKey);
            cmd.Parameters.AddWithValue("@AttemptCount", attemptCount);
            cmd.Parameters.AddWithValue("@WindowStartedAt", windowStartedAt);
            cmd.Parameters.AddWithValue("@BlockedUntil", (object)blockedUntil ?? DBNull.Value);
            cmd.Parameters.AddWithValue("@LastAttemptAt", nowUtc);
        }

        private static string BuildIdentityKey(string kind, string value)
        {
            string normalized = ValidationHelper.NormalizeIdentifier(value);
            if (string.IsNullOrEmpty(normalized))
                normalized = "unknown";

            return kind + ":" + normalized;
        }

        private static string BuildSingleIdentityKey(string value)
        {
            string normalized = ValidationHelper.NormalizeIdentifier(value);
            return string.IsNullOrEmpty(normalized) ? "unknown" : normalized;
        }

        private static string NormalizeAction(string action)
        {
            return ValidationHelper.NormalizeIdentifier(action);
        }

        private string GetConnectionString(string connectionName)
        {
            return ConfigurationManager.ConnectionStrings[connectionName].ConnectionString;
        }
    }
}
