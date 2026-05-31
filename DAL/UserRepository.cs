using System;
using System.Data;
using System.Data.Common;
using ONYX_DDAC.Models;

namespace ONYX_DDAC.DAL
{
    public class UserRepository
    {
        private readonly DbConnectionFactory connectionFactory;

        public UserRepository()
            : this(new DbConnectionFactory())
        {
        }

        public UserRepository(DbConnectionFactory connectionFactory)
        {
            this.connectionFactory = connectionFactory;
        }

        public User FindByEmail(string email)
        {
            using (DbConnection connection = connectionFactory.CreateDefaultConnection())
            using (DbCommand command = connection.CreateCommand())
            {
                command.CommandText = "SELECT id, fullname, username, email, password_hash, address, dob, phone_number, role, created_at FROM users WHERE email = @email";
                AddParameter(command, "@email", email);

                connection.Open();
                using (DbDataReader reader = command.ExecuteReader(CommandBehavior.SingleRow))
                {
                    if (!reader.Read())
                    {
                        return null;
                    }

                    return MapUser(reader);
                }
            }
        }

        private static void AddParameter(DbCommand command, string name, object value)
        {
            DbParameter parameter = command.CreateParameter();
            parameter.ParameterName = name;
            parameter.Value = value ?? DBNull.Value;
            command.Parameters.Add(parameter);
        }

        private static User MapUser(DbDataReader reader)
        {
            return new User
            {
                Id = Convert.ToInt64(reader["id"]),
                Fullname = Convert.ToString(reader["fullname"]),
                Username = Convert.ToString(reader["username"]),
                Email = Convert.ToString(reader["email"]),
                PasswordHash = Convert.ToString(reader["password_hash"]),
                Address = reader["address"] == DBNull.Value ? null : Convert.ToString(reader["address"]),
                Dob = reader["dob"] == DBNull.Value ? (DateTime?)null : Convert.ToDateTime(reader["dob"]),
                PhoneNumber = reader["phone_number"] == DBNull.Value ? null : Convert.ToString(reader["phone_number"]),
                Role = Convert.ToString(reader["role"]),
                CreatedAt = Convert.ToDateTime(reader["created_at"])
            };
        }
    }
}
