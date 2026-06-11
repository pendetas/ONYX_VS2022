using System;
using System.Data.Common;
using Npgsql;
using ONYX_DDAC.Models; 

namespace ONYX_DDAC.DAL
{
    public class UserRepository
    {
        // Inserts a new user into the database
        public bool CreateUser(User user)
        {
            using (DbConnection conn = DbConnectionFactory.CreateDefaultConnection())
            {
                conn.Open();
                using (DbCommand cmd = conn.CreateCommand())
                {
                    cmd.CommandText = @"
                    INSERT INTO users (fullname, username, email, password_hash, address, dob, phone_number, role, created_at) 
                    VALUES (@FullName, @Username, @Email, @PasswordHash, @Address, @Dob, @PhoneNumber, @Role, @CreatedAt)";

                    cmd.Parameters.Add(new NpgsqlParameter("@FullName", user.FullName));
                    cmd.Parameters.Add(new NpgsqlParameter("@Username", user.Username));
                    cmd.Parameters.Add(new NpgsqlParameter("@Email", user.Email));
                    cmd.Parameters.Add(new NpgsqlParameter("@PasswordHash", user.PasswordHash));
                    cmd.Parameters.Add(new NpgsqlParameter("@Address", (object)user.Address ?? DBNull.Value));
                    cmd.Parameters.Add(new NpgsqlParameter("@Dob", user.Dob.HasValue ? (object)user.Dob.Value : DBNull.Value));
                    cmd.Parameters.Add(new NpgsqlParameter("@PhoneNumber", (object)user.PhoneNumber ?? DBNull.Value));
                    cmd.Parameters.Add(new NpgsqlParameter("@Role", user.Role ?? "customer"));
                    cmd.Parameters.Add(new NpgsqlParameter("@CreatedAt", DateTime.UtcNow));

                    int rowsAffected = cmd.ExecuteNonQuery();
                    return rowsAffected > 0;
                }
            }
        }

        // Retrieves a user by email or username for login validation
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
                    WHERE lower(email) = lower(@LoginIdentifier)
                       OR lower(username) = lower(@LoginIdentifier)";

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
    }
}
