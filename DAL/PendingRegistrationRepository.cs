using System;
using System.Configuration;
using Npgsql;
using ONYX_DDAC.Helpers;
using ONYX_DDAC.Models;

namespace ONYX_DDAC.DAL
{
    public class PendingRegistrationRepository
    {
        public long ReplaceByEmail(PendingRegistration pending)
        {
            return CreateOrReplace(pending);
        }

        public long CreateOrReplace(PendingRegistration pending)
        {
            using (var conn = new NpgsqlConnection(GetConnectionString("DefaultConnection")))
            {
                conn.Open();
                using (var tx = conn.BeginTransaction())
                {
                    using (var delete = new NpgsqlCommand(@"
                        DELETE FROM pending_registrations
                        WHERE LOWER(email) = @Email", conn, tx))
                    {
                        delete.Parameters.AddWithValue("@Email", Normalize(pending.Email));
                        delete.ExecuteNonQuery();
                    }

                    using (var insert = new NpgsqlCommand(@"
                        INSERT INTO pending_registrations
                            (fullname, username, email, password_hash, address, dob, phone_number,
                             otp_hash, otp_expires_at, otp_attempts, resend_count, last_otp_sent_at, created_at)
                        VALUES
                            (@FullName, @Username, @Email, @PasswordHash, @Address, @Dob, @PhoneNumber,
                             @OtpHash, @OtpExpiresAt, @OtpAttempts, @ResendCount, @LastOtpSentAt, @CreatedAt)
                        RETURNING id", conn, tx))
                    {
                        AddPendingParameters(insert, pending);
                        long id = Convert.ToInt64(insert.ExecuteScalar());
                        tx.Commit();
                        return id;
                    }
                }
            }
        }

        public PendingRegistration GetByEmail(string email)
        {
            using (var conn = new NpgsqlConnection(GetConnectionString("DefaultConnection")))
            {
                conn.Open();
                using (var cmd = new NpgsqlCommand(@"
                    SELECT id, fullname, username, email, password_hash, address, dob, phone_number,
                           otp_hash, otp_expires_at, otp_attempts, resend_count, last_otp_sent_at, created_at
                    FROM pending_registrations
                    WHERE LOWER(email) = @Email
                    LIMIT 1", conn))
                {
                    cmd.Parameters.AddWithValue("@Email", Normalize(email));
                    using (var reader = cmd.ExecuteReader())
                    {
                        return reader.Read() ? Map(reader) : null;
                    }
                }
            }
        }

        public string CheckDuplicate(string username, string email)
        {
            using (var conn = new NpgsqlConnection(GetConnectionString("DefaultConnection")))
            {
                conn.Open();
                using (var cmd = new NpgsqlCommand(@"
                    SELECT
                        (SELECT COUNT(*) FROM pending_registrations WHERE LOWER(username) = @Username) AS un_count,
                        (SELECT COUNT(*) FROM pending_registrations WHERE LOWER(email) = @Email) AS em_count", conn))
                {
                    cmd.Parameters.AddWithValue("@Username", Normalize(username));
                    cmd.Parameters.AddWithValue("@Email", Normalize(email));

                    using (var reader = cmd.ExecuteReader())
                    {
                        if (reader.Read())
                        {
                            if (reader.GetInt64(0) > 0) return "username";
                            if (reader.GetInt64(1) > 0) return "email";
                        }
                    }
                }
            }

            return null;
        }

        public string CheckPendingConflict(string username, string email)
        {
            return CheckDuplicate(username, email);
        }

        public int IncrementOtpAttempts(string email)
        {
            using (var conn = new NpgsqlConnection(GetConnectionString("DefaultConnection")))
            {
                conn.Open();
                using (var cmd = new NpgsqlCommand(@"
                    UPDATE pending_registrations
                    SET otp_attempts = otp_attempts + 1
                    WHERE LOWER(email) = @Email
                    RETURNING otp_attempts", conn))
                {
                    cmd.Parameters.AddWithValue("@Email", Normalize(email));
                    object value = cmd.ExecuteScalar();
                    return value == null ? 0 : Convert.ToInt32(value);
                }
            }
        }

        public int IncrementOtpAttempts(long pendingRegistrationId)
        {
            using (var conn = new NpgsqlConnection(GetConnectionString("DefaultConnection")))
            {
                conn.Open();
                using (var cmd = new NpgsqlCommand(@"
                    UPDATE pending_registrations
                    SET otp_attempts = otp_attempts + 1
                    WHERE id = @Id
                    RETURNING otp_attempts", conn))
                {
                    cmd.Parameters.AddWithValue("@Id", pendingRegistrationId);
                    object value = cmd.ExecuteScalar();
                    return value == null ? 0 : Convert.ToInt32(value);
                }
            }
        }

        public bool UpdateOtp(string email, string otpHash, DateTime expiresAtUtc, DateTime sentAtUtc)
        {
            using (var conn = new NpgsqlConnection(GetConnectionString("DefaultConnection")))
            {
                conn.Open();
                using (var cmd = new NpgsqlCommand(@"
                    UPDATE pending_registrations
                    SET otp_hash = @OtpHash,
                        otp_expires_at = @OtpExpiresAt,
                        otp_attempts = 0,
                        resend_count = resend_count + 1,
                        last_otp_sent_at = @LastOtpSentAt
                    WHERE LOWER(email) = @Email", conn))
                {
                    cmd.Parameters.AddWithValue("@OtpHash", otpHash);
                    cmd.Parameters.AddWithValue("@OtpExpiresAt", expiresAtUtc);
                    cmd.Parameters.AddWithValue("@LastOtpSentAt", sentAtUtc);
                    cmd.Parameters.AddWithValue("@Email", Normalize(email));
                    return cmd.ExecuteNonQuery() > 0;
                }
            }
        }

        public bool DeleteByEmail(string email)
        {
            using (var conn = new NpgsqlConnection(GetConnectionString("DefaultConnection")))
            {
                conn.Open();
                using (var cmd = new NpgsqlCommand(
                    "DELETE FROM pending_registrations WHERE LOWER(email) = @Email", conn))
                {
                    cmd.Parameters.AddWithValue("@Email", Normalize(email));
                    return cmd.ExecuteNonQuery() > 0;
                }
            }
        }

        public bool Delete(long pendingRegistrationId)
        {
            using (var conn = new NpgsqlConnection(GetConnectionString("DefaultConnection")))
            {
                conn.Open();
                using (var cmd = new NpgsqlCommand(
                    "DELETE FROM pending_registrations WHERE id = @Id", conn))
                {
                    cmd.Parameters.AddWithValue("@Id", pendingRegistrationId);
                    return cmd.ExecuteNonQuery() > 0;
                }
            }
        }

        public int DeleteExpired(DateTime nowUtc)
        {
            using (var conn = new NpgsqlConnection(GetConnectionString("DefaultConnection")))
            {
                conn.Open();
                using (var cmd = new NpgsqlCommand(
                    "DELETE FROM pending_registrations WHERE otp_expires_at < @NowUtc", conn))
                {
                    cmd.Parameters.AddWithValue("@NowUtc", nowUtc);
                    return cmd.ExecuteNonQuery();
                }
            }
        }

        public bool UpdateOtpForResend(
            long pendingRegistrationId,
            string otpHash,
            DateTime expiresAtUtc,
            DateTime sentAtUtc,
            DateTime cooldownThresholdUtc,
            int maxResends)
        {
            using (var conn = new NpgsqlConnection(GetConnectionString("DefaultConnection")))
            {
                conn.Open();
                using (var cmd = new NpgsqlCommand(@"
                    UPDATE pending_registrations
                    SET otp_hash = @OtpHash,
                        otp_expires_at = @OtpExpiresAt,
                        otp_attempts = 0,
                        resend_count = resend_count + 1,
                        last_otp_sent_at = @LastOtpSentAt
                    WHERE id = @Id
                      AND resend_count < @MaxResends
                      AND last_otp_sent_at <= @CooldownThreshold", conn))
                {
                    cmd.Parameters.AddWithValue("@Id", pendingRegistrationId);
                    cmd.Parameters.AddWithValue("@OtpHash", otpHash);
                    cmd.Parameters.AddWithValue("@OtpExpiresAt", expiresAtUtc);
                    cmd.Parameters.AddWithValue("@LastOtpSentAt", sentAtUtc);
                    cmd.Parameters.AddWithValue("@MaxResends", maxResends);
                    cmd.Parameters.AddWithValue("@CooldownThreshold", cooldownThresholdUtc);
                    return cmd.ExecuteNonQuery() > 0;
                }
            }
        }

        public bool CompleteRegistration(
            long pendingRegistrationId,
            string otpHash,
            DateTime nowUtc,
            int maxOtpAttempts)
        {
            using (var conn = new NpgsqlConnection(GetConnectionString("DefaultConnection")))
            {
                conn.Open();
                using (var tx = conn.BeginTransaction())
                {
                    PendingRegistration pending;
                    using (var get = new NpgsqlCommand(@"
                        SELECT id, fullname, username, email, password_hash, address, dob, phone_number,
                               otp_hash, otp_expires_at, otp_attempts, resend_count, last_otp_sent_at, created_at
                        FROM pending_registrations
                        WHERE id = @Id
                          AND otp_hash = @OtpHash
                          AND otp_expires_at >= @NowUtc
                          AND otp_attempts < @MaxOtpAttempts
                        FOR UPDATE", conn, tx))
                    {
                        get.Parameters.AddWithValue("@Id", pendingRegistrationId);
                        get.Parameters.AddWithValue("@OtpHash", otpHash);
                        get.Parameters.AddWithValue("@NowUtc", nowUtc);
                        get.Parameters.AddWithValue("@MaxOtpAttempts", maxOtpAttempts);

                        using (var reader = get.ExecuteReader())
                        {
                            pending = reader.Read() ? Map(reader) : null;
                        }
                    }

                    if (pending == null)
                    {
                        tx.Rollback();
                        return false;
                    }

                    using (var insert = new NpgsqlCommand(@"
                        INSERT INTO users (fullname, username, email, password_hash, address, dob, phone_number, role, created_at)
                        VALUES (@FullName, @Username, @Email, @PasswordHash, @Address, @Dob, @PhoneNumber, @Role, @CreatedAt)", conn, tx))
                    {
                        insert.Parameters.AddWithValue("@FullName", pending.FullName);
                        insert.Parameters.AddWithValue("@Username", pending.Username);
                        insert.Parameters.AddWithValue("@Email", pending.Email);
                        insert.Parameters.AddWithValue("@PasswordHash", pending.PasswordHash);
                        insert.Parameters.AddWithValue("@Address", (object)pending.Address ?? DBNull.Value);
                        insert.Parameters.AddWithValue("@Dob", (object)pending.Dob ?? DBNull.Value);
                        insert.Parameters.AddWithValue("@PhoneNumber", (object)pending.PhoneNumber ?? DBNull.Value);
                        insert.Parameters.AddWithValue("@Role", "customer");
                        insert.Parameters.AddWithValue("@CreatedAt", nowUtc);
                        insert.ExecuteNonQuery();
                    }

                    using (var delete = new NpgsqlCommand(
                        "DELETE FROM pending_registrations WHERE id = @Id", conn, tx))
                    {
                        delete.Parameters.AddWithValue("@Id", pendingRegistrationId);
                        delete.ExecuteNonQuery();
                    }

                    tx.Commit();
                    return true;
                }
            }
        }

        private static void AddPendingParameters(NpgsqlCommand cmd, PendingRegistration pending)
        {
            cmd.Parameters.AddWithValue("@FullName", pending.FullName);
            cmd.Parameters.AddWithValue("@Username", pending.Username);
            cmd.Parameters.AddWithValue("@Email", pending.Email);
            cmd.Parameters.AddWithValue("@PasswordHash", pending.PasswordHash);
            cmd.Parameters.AddWithValue("@Address", (object)pending.Address ?? DBNull.Value);
            cmd.Parameters.AddWithValue("@Dob", (object)pending.Dob ?? DBNull.Value);
            cmd.Parameters.AddWithValue("@PhoneNumber", (object)pending.PhoneNumber ?? DBNull.Value);
            cmd.Parameters.AddWithValue("@OtpHash", pending.OtpHash);
            cmd.Parameters.AddWithValue("@OtpExpiresAt", pending.OtpExpiresAt);
            cmd.Parameters.AddWithValue("@OtpAttempts", pending.OtpAttempts);
            cmd.Parameters.AddWithValue("@ResendCount", pending.ResendCount);
            cmd.Parameters.AddWithValue("@LastOtpSentAt", pending.LastOtpSentAt);
            cmd.Parameters.AddWithValue("@CreatedAt", pending.CreatedAt);
        }

        private static PendingRegistration Map(NpgsqlDataReader reader)
        {
            return new PendingRegistration
            {
                Id = reader.GetInt64(0),
                FullName = reader.GetString(1),
                Username = reader.GetString(2),
                Email = reader.GetString(3),
                PasswordHash = reader.GetString(4),
                Address = reader.IsDBNull(5) ? null : reader.GetString(5),
                Dob = reader.IsDBNull(6) ? (DateTime?)null : reader.GetDateTime(6),
                PhoneNumber = reader.IsDBNull(7) ? null : reader.GetString(7),
                OtpHash = reader.GetString(8),
                OtpExpiresAt = reader.GetDateTime(9),
                OtpAttempts = reader.GetInt32(10),
                ResendCount = reader.GetInt32(11),
                LastOtpSentAt = reader.GetDateTime(12),
                CreatedAt = reader.GetDateTime(13)
            };
        }

        private static string Normalize(string value)
        {
            return ValidationHelper.NormalizeIdentifier(value);
        }

        private string GetConnectionString(string connectionName)
        {
            return ConfigurationManager.ConnectionStrings[connectionName].ConnectionString;
        }
    }
}
