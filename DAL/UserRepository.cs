using System;
using System.Configuration;
using Npgsql;
using ONYX_DDAC.Models; 

namespace ONYX_DDAC.DAL
{
    public class UserRepository
    {
        // Helper method to grab the connection string from Web.config
        private string GetConnectionString(string connectionName = "DefaultConnection")
        {
            return ConfigurationManager.ConnectionStrings[connectionName].ConnectionString;
        }

        // Inserts a new user into the database
        public bool CreateUser(User user)
        {
            // Explicitly initializing the Npgsql library connection right here
            using (var conn = new NpgsqlConnection(GetConnectionString("DefaultConnection")))
            {
                conn.Open();
                string sql = @"
                    INSERT INTO users (fullname, username, email, password_hash, address, dob, phone_number, role, created_at) 
                    VALUES (@FullName, @Username, @Email, @PasswordHash, @Address, @Dob, @PhoneNumber, @Role, @CreatedAt)";

                using (var cmd = new NpgsqlCommand(sql, conn))
                {
                    // Using parameters prevents SQL Injection attacks
                    cmd.Parameters.AddWithValue("@FullName", user.FullName);
                    cmd.Parameters.AddWithValue("@Username", user.Username);
                    cmd.Parameters.AddWithValue("@Email", user.Email);
                    cmd.Parameters.AddWithValue("@PasswordHash", user.PasswordHash);

                    // Handle nullable fields safely for PostgreSQL
                    cmd.Parameters.AddWithValue("@Address", (object)user.Address ?? DBNull.Value);
                    cmd.Parameters.AddWithValue("@Dob", user.Dob);
                    cmd.Parameters.AddWithValue("@PhoneNumber", (object)user.PhoneNumber ?? DBNull.Value);

                    cmd.Parameters.AddWithValue("@Role", user.Role ?? "customer"); // Default to customer
                    cmd.Parameters.AddWithValue("@CreatedAt", DateTime.UtcNow);

                    int rowsAffected = cmd.ExecuteNonQuery();
                    return rowsAffected > 0;
                }
            }
        }

        // Retrieves a user by email or username for login validation
        public User GetUserByEmailOrUsername(string emailOrUsername)
        {
            // Explicitly initializing the Npgsql library for reading
            using (var conn = new NpgsqlConnection(GetConnectionString("ReadConnection")))
            {
                conn.Open();
                string sql = @"
                    SELECT id, username, email, password_hash, role
                    FROM users
                    WHERE lower(email) = lower(@LoginIdentifier)
                       OR lower(username) = lower(@LoginIdentifier)";

                using (var cmd = new NpgsqlCommand(sql, conn))
                {
                    cmd.Parameters.AddWithValue("@LoginIdentifier", emailOrUsername);

                    using (var reader = cmd.ExecuteReader())
                    {
                        if (reader.Read())
                        {
                            return new User
                            {
                                Id = reader.GetInt64(0),
                                Username = reader.GetString(1),
                                Email = reader.GetString(2),
                                PasswordHash = reader.GetString(3),
                                Role = reader.GetString(4)
                            };
                        }
                    }
                }
            }
            return null; // User not found
        }

        public User GetUserById(long userId)
        {
            using (var conn = new NpgsqlConnection(GetConnectionString("ReadConnection")))
            {
                conn.Open();
                string sql = @"
                    SELECT id, fullname, username, email, address, dob, phone_number, role, created_at
                    FROM users
                    WHERE id = @UserId";

                using (var cmd = new NpgsqlCommand(sql, conn))
                {
                    cmd.Parameters.AddWithValue("@UserId", userId);

                    using (var reader = cmd.ExecuteReader())
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
            using (var conn = new NpgsqlConnection(GetConnectionString("DefaultConnection")))
            {
                conn.Open();
                string sql = @"
                    UPDATE users
                    SET fullname = @FullName,
                        email = @Email,
                        phone_number = @PhoneNumber,
                        address = @Address
                    WHERE id = @UserId";

                using (var cmd = new NpgsqlCommand(sql, conn))
                {
                    cmd.Parameters.AddWithValue("@UserId", userId);
                    cmd.Parameters.AddWithValue("@FullName", (object)fullName ?? DBNull.Value);
                    cmd.Parameters.AddWithValue("@Email", email);
                    cmd.Parameters.AddWithValue("@PhoneNumber", (object)phoneNumber ?? DBNull.Value);
                    cmd.Parameters.AddWithValue("@Address", (object)address ?? DBNull.Value);

                    return cmd.ExecuteNonQuery() > 0;
                }
            }
        }
    }
}
