using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data;
using System.Data.Common;
using Npgsql;
using ONYX_DDAC.Models;

namespace ONYX_DDAC.DAL
{
    public class UserRepository
    {
        // =====================================================================
        //  ADMIN QUERIES
        // =====================================================================

        public List<UserSummary> GetAllUsers()
        {
            var list = new List<UserSummary>();

            using (DbConnection conn = DbConnectionFactory.CreateReadConnection())
            {
                conn.Open();
                using (DbCommand cmd = conn.CreateCommand())
                {
                    cmd.CommandText = @"
                        SELECT
                            u.id,
                            COALESCE(NULLIF(TRIM(u.fullname), ''), u.username) AS full_name,
                            u.email,
                            COALESCE(u.phone_number, '—')                      AS phone,
                            u.role,
                            u.created_at,
                            COUNT(o.id)::int                                    AS total_orders,
                            COALESCE(SUM(o.total_amount) FILTER (WHERE o.status <> 'cancelled'), 0) AS total_spent
                        FROM users u
                        LEFT JOIN orders o ON o.user_id = u.id
                        GROUP BY u.id, u.fullname, u.username, u.email, u.phone_number, u.role, u.created_at
                        ORDER BY u.created_at DESC";

                    using (DbDataReader r = cmd.ExecuteReader())
                    {
                        while (r.Read())
                        {
                            string  fullName = r.GetString(1);
                            string  role     = r.GetString(4);
                            int     orders   = r.GetInt32(6);
                            decimal spent    = Convert.ToDecimal(r[7]);

                            list.Add(new UserSummary
                            {
                                Id          = r.GetInt64(0),
                                FullName    = fullName,
                                Email       = r.GetString(2),
                                Phone       = r.GetString(3),
                                Role        = string.IsNullOrEmpty(role) ? "Unknown" : char.ToUpper(role[0]) + role.Substring(1),
                                RoleKey     = string.IsNullOrEmpty(role) ? "" : role.ToLower(),
                                Initials    = GetInitials(fullName),
                                JoinDate    = r.GetDateTime(5).ToString("d MMM yyyy"),
                                TotalOrders = orders == 0 ? "0" : orders.ToString(),
                                TotalSpent  = spent == 0m ? "—" : "RM " + spent.ToString("N2"),
                                SpentClass  = spent == 0m ? "spent-dash" : "spent-value"
                            });
                        }
                    }
                }
            }

            return list;
        }

        public UserStats GetStats()
        {
            using (DbConnection conn = DbConnectionFactory.CreateReadConnection())
            {
                conn.Open();
                using (DbCommand cmd = conn.CreateCommand())
                {
                    cmd.CommandText = @"
                        SELECT
                            COUNT(*)                                                              AS total,
                            COUNT(*) FILTER (WHERE role = 'admin')                               AS admins,
                            COUNT(*) FILTER (WHERE role = 'customer')                            AS customers,
                            COUNT(*) FILTER (WHERE created_at >= DATE_TRUNC('month', NOW()))     AS new_this_month,
                            (SELECT COALESCE(SUM(total_amount), 0) FROM orders WHERE status <> 'cancelled') AS platform_revenue
                        FROM users";

                    using (DbDataReader r = cmd.ExecuteReader())
                    {
                        if (r.Read())
                        {
                            return new UserStats
                            {
                                Total           = Convert.ToInt32(r[0]),
                                Admins          = Convert.ToInt32(r[1]),
                                Customers       = Convert.ToInt32(r[2]),
                                NewThisMonth    = Convert.ToInt32(r[3]),
                                PlatformRevenue = Convert.ToDecimal(r[4])
                            };
                        }
                    }
                }
            }
            return new UserStats();
        }

        // =====================================================================
        //  DETAIL CRUD
        // =====================================================================

        public UserDetail GetAdminUserById(long id)
        {
            using (DbConnection conn = DbConnectionFactory.CreateReadConnection())
            {
                conn.Open();
                using (DbCommand cmd = conn.CreateCommand())
                {
                    cmd.CommandText = @"
                        SELECT
                            u.id,
                            COALESCE(NULLIF(TRIM(u.fullname), ''), u.username) AS full_name,
                            u.username,
                            u.email,
                            COALESCE(u.phone_number, '')  AS phone,
                            COALESCE(u.address, '')       AS address,
                            COALESCE(CAST(u.dob AS TEXT), '') AS dob,
                            u.role,
                            u.created_at,
                            COUNT(o.id)::int                                                           AS total_orders,
                            COALESCE(SUM(o.total_amount) FILTER (WHERE o.status <> 'cancelled'), 0)   AS total_spent
                        FROM users u
                        LEFT JOIN orders o ON o.user_id = u.id
                        WHERE u.id = @Id
                        GROUP BY u.id, u.fullname, u.username, u.email, u.phone_number, u.address, u.dob, u.role, u.created_at";

                    DbParameter p = cmd.CreateParameter();
                    p.ParameterName = "@Id";
                    p.Value = id;
                    cmd.Parameters.Add(p);

                    using (DbDataReader r = cmd.ExecuteReader())
                    {
                        if (r.Read())
                        {
                            string fullName = r.GetString(1);
                            return new UserDetail
                            {
                                Id          = r.GetInt64(0),
                                FullName    = fullName,
                                Username    = r.GetString(2),
                                Email       = r.GetString(3),
                                Phone       = r.GetString(4),
                                Address     = r.GetString(5),
                                Dob         = r.GetString(6),
                                Role        = r.GetString(7),
                                Initials    = GetInitials(fullName),
                                CreatedAt   = r.GetDateTime(8),
                                TotalOrders = r.GetInt32(9),
                                TotalSpent  = Convert.ToDecimal(r[10])
                            };
                        }
                    }
                }
            }
            return null;
        }

        public List<UserOrderSummary> GetUserOrders(long userId)
        {
            var list = new List<UserOrderSummary>();

            using (DbConnection conn = DbConnectionFactory.CreateReadConnection())
            {
                conn.Open();
                using (DbCommand cmd = conn.CreateCommand())
                {
                    cmd.CommandText = @"
                        SELECT id, ordered_at, total_amount, status
                        FROM orders
                        WHERE user_id = @UserId
                        ORDER BY ordered_at DESC
                        LIMIT 10";

                    DbParameter p = cmd.CreateParameter();
                    p.ParameterName = "@UserId";
                    p.Value = userId;
                    cmd.Parameters.Add(p);

                    using (DbDataReader r = cmd.ExecuteReader())
                    {
                        while (r.Read())
                        {
                            string status = r.GetString(3);
                            list.Add(new UserOrderSummary
                            {
                                RawId     = r.GetInt64(0),
                                OrderId   = "#ORD-" + r.GetInt64(0),
                                Date      = r.GetDateTime(1).ToString("d MMM yyyy"),
                                Total     = "RM " + Convert.ToDecimal(r[2]).ToString("N2"),
                                Status    = string.IsNullOrEmpty(status) ? "Unknown" : char.ToUpper(status[0]) + status.Substring(1),
                                StatusKey = string.IsNullOrEmpty(status) ? "" : status.ToLower()
                            });
                        }
                    }
                }
            }
            return list;
        }

        public void UpdateUser(long id, string fullName, string email, string phone, string address, string role)
        {
            using (DbConnection conn = DbConnectionFactory.CreateDefaultConnection())
            {
                conn.Open();
                using (DbCommand cmd = conn.CreateCommand())
                {
                    cmd.CommandText = @"
                        UPDATE users SET
                            fullname     = @FullName,
                            email        = @Email,
                            phone_number = NULLIF(@Phone, ''),
                            address      = NULLIF(@Address, ''),
                            role         = @Role
                        WHERE id = @Id";

                    void AddParam(string name, object val) {
                        DbParameter p = cmd.CreateParameter();
                        p.ParameterName = name;
                        p.Value = val ?? DBNull.Value;
                        cmd.Parameters.Add(p);
                    }

                    AddParam("@FullName", fullName);
                    AddParam("@Email",    email);
                    AddParam("@Phone",    phone);
                    AddParam("@Address",  address);
                    AddParam("@Role",     role);
                    AddParam("@Id",       id);

                    cmd.ExecuteNonQuery();
                }
            }
        }

        public void DeleteUser(long id)
        {
            using (DbConnection conn = DbConnectionFactory.CreateDefaultConnection())
            {
                conn.Open();
                using (DbTransaction tx = conn.BeginTransaction())
                {
                    using (DbCommand cmd = conn.CreateCommand())
                    {
                        cmd.Transaction = tx;

                        cmd.CommandText = "DELETE FROM wishlists WHERE user_id = @Id";
                        DbParameter p0 = cmd.CreateParameter(); p0.ParameterName = "@Id"; p0.Value = id;
                        cmd.Parameters.Add(p0);
                        cmd.ExecuteNonQuery();

                        cmd.Parameters.Clear();
                        cmd.CommandText = "DELETE FROM reviews WHERE user_id = @Id";
                        DbParameter p1 = cmd.CreateParameter(); p1.ParameterName = "@Id"; p1.Value = id;
                        cmd.Parameters.Add(p1);
                        cmd.ExecuteNonQuery();

                        cmd.Parameters.Clear();
                        cmd.CommandText = "DELETE FROM order_items WHERE order_id IN (SELECT id FROM orders WHERE user_id = @Id)";
                        DbParameter p2 = cmd.CreateParameter(); p2.ParameterName = "@Id"; p2.Value = id;
                        cmd.Parameters.Add(p2);
                        cmd.ExecuteNonQuery();

                        cmd.Parameters.Clear();
                        cmd.CommandText = "DELETE FROM orders WHERE user_id = @Id";
                        DbParameter p3 = cmd.CreateParameter(); p3.ParameterName = "@Id"; p3.Value = id;
                        cmd.Parameters.Add(p3);
                        cmd.ExecuteNonQuery();

                        cmd.Parameters.Clear();
                        cmd.CommandText = "DELETE FROM users WHERE id = @Id";
                        DbParameter p4 = cmd.CreateParameter(); p4.ParameterName = "@Id"; p4.Value = id;
                        cmd.Parameters.Add(p4);
                        cmd.ExecuteNonQuery();
                    }
                    tx.Commit();
                }
            }
        }

        public List<UserSummary> GetAdminList()
        {
            var list = new List<UserSummary>();

            using (DbConnection conn = DbConnectionFactory.CreateReadConnection())
            {
                conn.Open();
                using (DbCommand cmd = conn.CreateCommand())
                {
                    cmd.CommandText = @"
                        SELECT
                            id,
                            COALESCE(NULLIF(TRIM(fullname), ''), username) AS full_name,
                            email,
                            created_at
                        FROM users
                        WHERE role = 'admin'
                        ORDER BY created_at ASC";

                    using (DbDataReader r = cmd.ExecuteReader())
                    {
                        while (r.Read())
                        {
                            string fullName = r.GetString(1);
                            list.Add(new UserSummary
                            {
                                Id       = r.GetInt64(0),
                                FullName = fullName,
                                Email    = r.GetString(2),
                                JoinDate = r.GetDateTime(3).ToString("d MMM yyyy"),
                                Role     = "Admin",
                                RoleKey  = "admin",
                                Initials = GetInitials(fullName)
                            });
                        }
                    }
                }
            }
            return list;
        }

        // =====================================================================
        //  AUTH HELPERS (used by AuthService)
        // =====================================================================

        public bool CreateUser(User user)
        {
            using (var conn = new NpgsqlConnection(GetConnectionString("DefaultConnection")))
            {
                conn.Open();
                string sql = @"
                    INSERT INTO users (fullname, username, email, password_hash, address, dob, phone_number, role, created_at)
                    VALUES (@FullName, @Username, @Email, @PasswordHash, @Address, @Dob, @PhoneNumber, @Role, @CreatedAt)";

                using (var cmd = new NpgsqlCommand(sql, conn))
                {
                    cmd.Parameters.AddWithValue("@FullName",     user.FullName);
                    cmd.Parameters.AddWithValue("@Username",     user.Username);
                    cmd.Parameters.AddWithValue("@Email",        user.Email);
                    cmd.Parameters.AddWithValue("@PasswordHash", user.PasswordHash);
                    cmd.Parameters.AddWithValue("@Address",      (object)user.Address ?? DBNull.Value);
                    cmd.Parameters.AddWithValue("@Dob",          user.Dob);
                    cmd.Parameters.AddWithValue("@PhoneNumber",  (object)user.PhoneNumber ?? DBNull.Value);
                    cmd.Parameters.AddWithValue("@Role",         user.Role ?? "customer");
                    cmd.Parameters.AddWithValue("@CreatedAt",    DateTime.UtcNow);

                    return cmd.ExecuteNonQuery() > 0;
                }
            }
        }

        public User CreateOAuthUser(OAuthProfile profile, string username)
        {
            using (var conn = new NpgsqlConnection(GetConnectionString("DefaultConnection")))
            {
                conn.Open();
                using (var tx = conn.BeginTransaction())
                {
                    const string sql = @"
                        INSERT INTO users (
                            fullname,
                            username,
                            email,
                            password_hash,
                            role,
                            created_at)
                        VALUES (
                            @FullName,
                            @Username,
                            @Email,
                            NULL,
                            'customer',
                            @CreatedAt)
                        RETURNING id, username, email, password_hash, role, fullname";

                    User user;
                    using (var cmd = new NpgsqlCommand(sql, conn, tx))
                    {
                        DateTime now = DateTime.UtcNow;
                        cmd.Parameters.AddWithValue("@FullName", profile.FullName);
                        cmd.Parameters.AddWithValue("@Username", username);
                        cmd.Parameters.AddWithValue("@Email", profile.Email);
                        cmd.Parameters.AddWithValue("@CreatedAt", now);

                        using (var reader = cmd.ExecuteReader())
                        {
                            user = reader.Read() ? ReadAuthUser(reader) : null;
                        }
                    }

                    if (user != null)
                        UpsertOAuthAccount(conn, tx, user.Id, profile);

                    tx.Commit();
                    return user;
                }
            }
        }

        public User GetUserByOAuthAccount(string provider, string providerUserId)
        {
            using (var conn = new NpgsqlConnection(GetConnectionString("DefaultConnection")))
            {
                conn.Open();
                const string sql = @"
                    SELECT u.id, u.username, u.email, u.password_hash, u.role, u.fullname
                    FROM user_oauth_accounts a
                    INNER JOIN users u ON u.id = a.user_id
                    WHERE LOWER(a.provider) = @Provider
                      AND a.provider_user_id = @ProviderUserId
                    LIMIT 1";

                using (var cmd = new NpgsqlCommand(sql, conn))
                {
                    cmd.Parameters.AddWithValue("@Provider", NormalizeOAuthProvider(provider));
                    cmd.Parameters.AddWithValue("@ProviderUserId", providerUserId);
                    using (var reader = cmd.ExecuteReader())
                    {
                        return reader.Read() ? ReadAuthUser(reader) : null;
                    }
                }
            }
        }

        public void LinkOAuthAccount(long userId, OAuthProfile profile)
        {
            using (var conn = new NpgsqlConnection(GetConnectionString("DefaultConnection")))
            {
                conn.Open();
                using (var tx = conn.BeginTransaction())
                {
                    UpsertOAuthAccount(conn, tx, userId, profile);
                    tx.Commit();
                }
            }
        }

        public bool UsernameExists(string username)
        {
            using (var conn = new NpgsqlConnection(GetConnectionString("DefaultConnection")))
            {
                conn.Open();
                const string sql = "SELECT COUNT(*) FROM users WHERE LOWER(username) = @Username";
                using (var cmd = new NpgsqlCommand(sql, conn))
                {
                    cmd.Parameters.AddWithValue("@Username", (username ?? string.Empty).Trim().ToLowerInvariant());
                    return (long)cmd.ExecuteScalar() > 0;
                }
            }
        }

        public string CheckDuplicate(string username, string email)
        {
            using (var conn = new NpgsqlConnection(GetConnectionString("DefaultConnection")))
            {
                conn.Open();
                string sql = @"
                    SELECT
                        (SELECT COUNT(*) FROM users WHERE LOWER(username) = LOWER(@Username)) AS un_count,
                        (SELECT COUNT(*) FROM users WHERE LOWER(email)    = LOWER(@Email))    AS em_count";

                using (var cmd = new NpgsqlCommand(sql, conn))
                {
                    cmd.Parameters.AddWithValue("@Username", username);
                    cmd.Parameters.AddWithValue("@Email",    email);

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

        public User GetUserByEmail(string email)
        {
            return GetUserByEmailInternal(email, "ReadConnection");
        }

        public User GetUserByEmailForWrite(string email)
        {
            return GetUserByEmailInternal(email, "DefaultConnection");
        }

        public User GetUserByUsername(string username)
        {
            using (var conn = new NpgsqlConnection(GetConnectionString("ReadConnection")))
            {
                conn.Open();
                string sql = "SELECT id, username, email, password_hash, role FROM users WHERE LOWER(username) = LOWER(@Username)";

                using (var cmd = new NpgsqlCommand(sql, conn))
                {
                    cmd.Parameters.AddWithValue("@Username", username);

                    using (var reader = cmd.ExecuteReader())
                    {
                        if (reader.Read())
                        {
                            return new User
                            {
                                Id           = reader.GetInt64(0),
                                Username     = reader.GetString(1),
                                Email        = reader.GetString(2),
                                PasswordHash = reader.GetString(3),
                                Role         = reader.GetString(4)
                            };
                        }
                    }
                }
            }
            return null;
        }

        public void UpdatePasswordHash(long userId, string newHash)
        {
            using (var conn = new NpgsqlConnection(GetConnectionString("DefaultConnection")))
            {
                conn.Open();
                using (var cmd = new NpgsqlCommand(
                    "UPDATE users SET password_hash = @Hash WHERE id = @Id", conn))
                {
                    cmd.Parameters.AddWithValue("@Hash", newHash);
                    cmd.Parameters.AddWithValue("@Id",   userId);
                    cmd.ExecuteNonQuery();
                }
            }
        }

        public void CreatePasswordResetToken(
            long userId,
            string tokenHash,
            int expiryMinutes)
        {
            using (var conn = new NpgsqlConnection(GetConnectionString("DefaultConnection")))
            {
                conn.Open();
                using (var tx = conn.BeginTransaction())
                {
                    using (var expireCmd = new NpgsqlCommand(
                        @"UPDATE password_reset_tokens
                          SET used_at = NOW()
                          WHERE user_id = @UserId
                            AND used_at IS NULL", conn, tx))
                    {
                        expireCmd.Parameters.AddWithValue("@UserId", userId);
                        expireCmd.ExecuteNonQuery();
                    }

                    using (var insertCmd = new NpgsqlCommand(
                        @"INSERT INTO password_reset_tokens
                            (user_id, token_hash, expires_at, created_at)
                          VALUES
                            (@UserId, @TokenHash, NOW() + (@ExpiryMinutes * INTERVAL '1 minute'), NOW())", conn, tx))
                    {
                        insertCmd.Parameters.AddWithValue("@UserId", userId);
                        insertCmd.Parameters.AddWithValue("@TokenHash", tokenHash);
                        insertCmd.Parameters.AddWithValue("@ExpiryMinutes", expiryMinutes);
                        insertCmd.ExecuteNonQuery();
                    }

                    tx.Commit();
                }
            }
        }

        public long? GetValidPasswordResetUserId(string tokenHash)
        {
            using (var conn = new NpgsqlConnection(GetConnectionString("ReadConnection")))
            {
                conn.Open();
                using (var cmd = new NpgsqlCommand(
                        @"SELECT user_id
                      FROM password_reset_tokens
                      WHERE token_hash = @TokenHash
                        AND used_at IS NULL
                        AND expires_at > NOW()
                      LIMIT 1", conn))
                {
                    cmd.Parameters.AddWithValue("@TokenHash", tokenHash);
                    object result = cmd.ExecuteScalar();
                    if (result == null || result == DBNull.Value)
                        return null;

                    return Convert.ToInt64(result);
                }
            }
        }

        public bool ResetPasswordWithToken(string tokenHash, string newPasswordHash)
        {
            using (var conn = new NpgsqlConnection(GetConnectionString("DefaultConnection")))
            {
                conn.Open();
                using (var tx = conn.BeginTransaction())
                {
                    long resetTokenId;
                    long userId;

                    using (var selectCmd = new NpgsqlCommand(
                        @"SELECT id, user_id
                          FROM password_reset_tokens
                          WHERE token_hash = @TokenHash
                            AND used_at IS NULL
                            AND expires_at > NOW()
                          FOR UPDATE", conn, tx))
                    {
                        selectCmd.Parameters.AddWithValue("@TokenHash", tokenHash);

                        using (var reader = selectCmd.ExecuteReader())
                        {
                            if (!reader.Read())
                                return false;

                            resetTokenId = reader.GetInt64(0);
                            userId = reader.GetInt64(1);
                        }
                    }

                    using (var updateUserCmd = new NpgsqlCommand(
                        @"UPDATE users
                          SET password_hash = @PasswordHash
                          WHERE id = @UserId", conn, tx))
                    {
                        updateUserCmd.Parameters.AddWithValue("@PasswordHash", newPasswordHash);
                        updateUserCmd.Parameters.AddWithValue("@UserId", userId);
                        if (updateUserCmd.ExecuteNonQuery() == 0)
                            return false;
                    }

                    using (var useTokenCmd = new NpgsqlCommand(
                        @"UPDATE password_reset_tokens
                          SET used_at = NOW()
                          WHERE id = @Id", conn, tx))
                    {
                        useTokenCmd.Parameters.AddWithValue("@Id", resetTokenId);
                        useTokenCmd.ExecuteNonQuery();
                    }

                    tx.Commit();
                    return true;
                }
            }
        }

        public User GetUserByEmailOrUsername(string emailOrUsername)
        {
            using (DbConnection conn = DbConnectionFactory.CreateReadConnection())
            {
                conn.Open();
                using (DbCommand cmd = conn.CreateCommand())
                {
                    cmd.CommandText = @"
                        SELECT id, username, email, password_hash, role
                        FROM users
                        WHERE LOWER(email) = LOWER(@LoginIdentifier)
                           OR LOWER(username) = LOWER(@LoginIdentifier)";
                    cmd.Parameters.Add(new NpgsqlParameter("@LoginIdentifier", emailOrUsername));

                    using (DbDataReader reader = cmd.ExecuteReader())
                    {
                        if (reader.Read())
                        {
                            return new User
                            {
                                Id = reader.GetInt64(0),
                                Username = reader.GetString(1),
                                Email = reader.GetString(2),
                                PasswordHash = reader.IsDBNull(3) ? null : reader.GetString(3),
                                Role = reader.GetString(4)
                            };
                        }
                    }
                }
            }
            return null;
        }

        public User GetUserById(long userId)
        {
            using (DbConnection conn = DbConnectionFactory.CreateReadConnection())
            {
                conn.Open();
                using (DbCommand cmd = conn.CreateCommand())
                {
                    cmd.CommandText = @"
                        SELECT id, fullname, username, email, address, dob, phone_number, role, created_at
                        FROM users
                        WHERE id = @UserId";
                    cmd.Parameters.Add(new NpgsqlParameter("@UserId", userId));

                    using (DbDataReader reader = cmd.ExecuteReader())
                    {
                        if (reader.Read())
                        {
                            return new User
                            {
                                Id = reader.GetInt64(reader.GetOrdinal("id")),
                                FullName = reader.IsDBNull(reader.GetOrdinal("fullname")) ? null : reader.GetString(reader.GetOrdinal("fullname")),
                                Username = reader.IsDBNull(reader.GetOrdinal("username")) ? null : reader.GetString(reader.GetOrdinal("username")),
                                Email = reader.IsDBNull(reader.GetOrdinal("email")) ? null : reader.GetString(reader.GetOrdinal("email")),
                                Address = reader.IsDBNull(reader.GetOrdinal("address")) ? null : reader.GetString(reader.GetOrdinal("address")),
                                Dob = reader.IsDBNull(reader.GetOrdinal("dob")) ? (DateTime?)null : reader.GetDateTime(reader.GetOrdinal("dob")),
                                PhoneNumber = reader.IsDBNull(reader.GetOrdinal("phone_number")) ? null : reader.GetString(reader.GetOrdinal("phone_number")),
                                Role = reader.IsDBNull(reader.GetOrdinal("role")) ? null : reader.GetString(reader.GetOrdinal("role")),
                                CreatedAt = reader.GetDateTime(reader.GetOrdinal("created_at"))
                            };
                        }
                    }
                }
            }

            return null;
        }

        public bool UpdateUserSettings(long userId, string fullName, string email, string phoneNumber, string address)
        {
            using (DbConnection conn = DbConnectionFactory.CreateDefaultConnection())
            {
                conn.Open();
                using (DbCommand cmd = conn.CreateCommand())
                {
                    cmd.CommandText = @"
                        UPDATE users
                        SET fullname = @FullName,
                            email = @Email,
                            phone_number = @PhoneNumber,
                            address = @Address
                        WHERE id = @UserId";
                    cmd.Parameters.Add(new NpgsqlParameter("@UserId", userId));
                    cmd.Parameters.Add(new NpgsqlParameter("@FullName", (object)fullName ?? DBNull.Value));
                    cmd.Parameters.Add(new NpgsqlParameter("@Email", email));
                    cmd.Parameters.Add(new NpgsqlParameter("@PhoneNumber", (object)phoneNumber ?? DBNull.Value));
                    cmd.Parameters.Add(new NpgsqlParameter("@Address", (object)address ?? DBNull.Value));

                    return cmd.ExecuteNonQuery() > 0;
                }
            }
        }

        // =====================================================================
        //  PRIVATE HELPERS
        // =====================================================================

        private static string GetInitials(string fullName)
        {
            if (string.IsNullOrWhiteSpace(fullName)) return "?";
            string[] parts = fullName.Trim().Split(new[] { ' ' }, StringSplitOptions.RemoveEmptyEntries);
            if (parts.Length == 1) return parts[0].Substring(0, Math.Min(2, parts[0].Length)).ToUpper();
            return (parts[0][0].ToString() + parts[parts.Length - 1][0].ToString()).ToUpper();
        }

        private User GetUserByEmailInternal(string email, string connectionName)
        {
            using (var conn = new NpgsqlConnection(GetConnectionString(connectionName)))
            {
                conn.Open();
                const string sql =
                    "SELECT id, username, email, password_hash, role, fullname FROM users WHERE LOWER(email) = LOWER(@Email)";

                using (var cmd = new NpgsqlCommand(sql, conn))
                {
                    cmd.Parameters.AddWithValue("@Email", email);

                    using (var reader = cmd.ExecuteReader())
                    {
                        return reader.Read() ? ReadAuthUser(reader) : null;
                    }
                }
            }
        }

        private static void UpsertOAuthAccount(
            NpgsqlConnection conn,
            NpgsqlTransaction tx,
            long userId,
            OAuthProfile profile)
        {
            string provider = NormalizeOAuthProvider(profile.Provider);
            const string sql = @"
                INSERT INTO user_oauth_accounts (
                    user_id,
                    provider,
                    provider_user_id,
                    email,
                    email_verified,
                    display_name,
                    avatar_url,
                    created_at,
                    last_login_at)
                VALUES (
                    @UserId,
                    @Provider,
                    @ProviderUserId,
                    @Email,
                    @EmailVerified,
                    @DisplayName,
                    @AvatarUrl,
                    @Now,
                    @Now)
                ON CONFLICT (provider, provider_user_id)
                DO UPDATE SET
                    user_id = EXCLUDED.user_id,
                    email = EXCLUDED.email,
                    email_verified = EXCLUDED.email_verified,
                    display_name = EXCLUDED.display_name,
                    avatar_url = COALESCE(EXCLUDED.avatar_url, user_oauth_accounts.avatar_url),
                    last_login_at = EXCLUDED.last_login_at";

            using (var cmd = new NpgsqlCommand(sql, conn, tx))
            {
                cmd.Parameters.AddWithValue("@UserId", userId);
                cmd.Parameters.AddWithValue("@Provider", provider);
                cmd.Parameters.AddWithValue("@ProviderUserId", profile.Subject);
                cmd.Parameters.AddWithValue("@Email", (object)profile.Email ?? DBNull.Value);
                cmd.Parameters.AddWithValue("@EmailVerified", profile.EmailVerified);
                cmd.Parameters.AddWithValue("@DisplayName", (object)profile.FullName ?? DBNull.Value);
                cmd.Parameters.AddWithValue("@AvatarUrl", (object)profile.AvatarUrl ?? DBNull.Value);
                cmd.Parameters.AddWithValue("@Now", DateTime.UtcNow);
                cmd.ExecuteNonQuery();
            }
        }

        private static User ReadAuthUser(IDataRecord reader)
        {
            return new User
            {
                Id = reader.GetInt64(0),
                Username = reader.GetString(1),
                Email = reader.GetString(2),
                PasswordHash = reader.IsDBNull(3) ? null : reader.GetString(3),
                Role = reader.GetString(4),
                FullName = reader.FieldCount > 5 && !reader.IsDBNull(5) ? reader.GetString(5) : null
            };
        }

        private static string NormalizeOAuthProvider(string provider)
        {
            if (string.IsNullOrWhiteSpace(provider))
                throw new InvalidOperationException("OAuth provider is required.");

            return provider.Trim().ToLowerInvariant();
        }

        private string GetConnectionString(string connectionName = "DefaultConnection")
        {
            string host = GetEnvironmentValue("ONYX_DB_HOST");
            string portValue = GetEnvironmentValue("ONYX_DB_PORT");
            string database = GetEnvironmentValue("ONYX_DB_NAME");
            string username = GetEnvironmentValue("ONYX_DB_USER");
            string password = GetEnvironmentValue("ONYX_DB_PASSWORD");

            bool hasAnyRdsSetting =
                !string.IsNullOrWhiteSpace(host) ||
                !string.IsNullOrWhiteSpace(portValue) ||
                !string.IsNullOrWhiteSpace(database) ||
                !string.IsNullOrWhiteSpace(username) ||
                !string.IsNullOrWhiteSpace(password);

            if (hasAnyRdsSetting)
            {
                if (string.IsNullOrWhiteSpace(host) ||
                    string.IsNullOrWhiteSpace(portValue) ||
                    string.IsNullOrWhiteSpace(database) ||
                    string.IsNullOrWhiteSpace(username) ||
                    string.IsNullOrWhiteSpace(password))
                {
                    throw new ConfigurationErrorsException(
                        "RDS database configuration is incomplete. Check ONYX_DB_HOST, ONYX_DB_PORT, ONYX_DB_NAME, ONYX_DB_USER, and ONYX_DB_PASSWORD.");
                }

                int port;
                if (!int.TryParse(portValue, out port) || port < 1 || port > 65535)
                    throw new ConfigurationErrorsException("ONYX_DB_PORT must be a valid TCP port number.");

                return new NpgsqlConnectionStringBuilder
                {
                    Host = host,
                    Port = port,
                    Database = database,
                    Username = username,
                    Password = password,
                    SslMode = SslMode.Require,
                    TrustServerCertificate = true,
                    Pooling = true,
                    MinPoolSize = 1,
                    MaxPoolSize = 100,
                    KeepAlive = 30
                }.ConnectionString;
            }

            return ConfigurationManager.ConnectionStrings[connectionName].ConnectionString;
        }

        private static string GetEnvironmentValue(string variableName)
        {
            string value = Environment.GetEnvironmentVariable(variableName);

            if (string.IsNullOrWhiteSpace(value))
                value = Environment.GetEnvironmentVariable(variableName, EnvironmentVariableTarget.User);

            return value;
        }
    }
}
