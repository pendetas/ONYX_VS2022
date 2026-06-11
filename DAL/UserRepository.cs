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
                                Role        = char.ToUpper(role[0]) + role.Substring(1),
                                RoleKey     = role.ToLower(),
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

        public UserDetail GetUserById(long id)
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
                                Status    = char.ToUpper(status[0]) + status.Substring(1),
                                StatusKey = status.ToLower()
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

                        cmd.CommandText = "DELETE FROM order_items WHERE order_id IN (SELECT id FROM orders WHERE user_id = @Id)";
                        DbParameter p1 = cmd.CreateParameter(); p1.ParameterName = "@Id"; p1.Value = id;
                        cmd.Parameters.Add(p1);
                        cmd.ExecuteNonQuery();

                        cmd.Parameters.Clear();
                        cmd.CommandText = "DELETE FROM orders WHERE user_id = @Id";
                        DbParameter p2 = cmd.CreateParameter(); p2.ParameterName = "@Id"; p2.Value = id;
                        cmd.Parameters.Add(p2);
                        cmd.ExecuteNonQuery();

                        cmd.Parameters.Clear();
                        cmd.CommandText = "DELETE FROM users WHERE id = @Id";
                        DbParameter p3 = cmd.CreateParameter(); p3.ParameterName = "@Id"; p3.Value = id;
                        cmd.Parameters.Add(p3);
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
            using (var conn = new NpgsqlConnection(GetConnectionString("ReadConnection")))
            {
                conn.Open();
                string sql = "SELECT id, username, email, password_hash, role FROM users WHERE email = @Email";

                using (var cmd = new NpgsqlCommand(sql, conn))
                {
                    cmd.Parameters.AddWithValue("@Email", email);

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

        private string GetConnectionString(string connectionName = "DefaultConnection")
        {
            return ConfigurationManager.ConnectionStrings[connectionName].ConnectionString;
        }
    }
}
