using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data.Common;
using Npgsql;

namespace ONYX_DDAC.DAL
{
    /// <summary>
    /// Creates database connections from the configured RDS environment variables,
    /// with Web.config connection strings retained as a local-development fallback.
    /// </summary>
    public static class DbConnectionFactory
    {
        private const string DefaultConnectionName = "DefaultConnection";
        private const string ReadConnectionName = "ReadConnection";
        private static readonly string[] RdsEnvironmentVariableNames =
        {
            "ONYX_DB_HOST",
            "ONYX_DB_PORT",
            "ONYX_DB_NAME",
            "ONYX_DB_USER",
            "ONYX_DB_PASSWORD"
        };

        /// <summary>
        /// Creates a connection to the primary database. Use this for ALL INSERT, UPDATE, and DELETE operations.
        /// </summary>
        public static DbConnection CreateDefaultConnection()
        {
            if (IsRdsEnvironmentConfigured())
            {
                return CreateRdsConnection();
            }

            return CreateConnection(DefaultConnectionName);
        }

        /// <summary>
        /// Creates the configured read connection. RDS reads currently use the primary
        /// because this environment does not have a read replica.
        /// </summary>
        public static DbConnection CreateReadConnection()
        {
            // The current RDS setup has no read replica. Keep all RDS reads and writes
            // on the same database so reads cannot accidentally fall back to localhost.
            if (IsRdsEnvironmentConfigured())
            {
                return CreateRdsConnection();
            }

            ConnectionStringSettings readSettings = ConfigurationManager.ConnectionStrings[ReadConnectionName];

            // If no read connection string is defined at all, default to primary.
            if (readSettings == null || string.IsNullOrWhiteSpace(readSettings.ConnectionString))
            {
                return CreateDefaultConnection();
            }

            try
            {
                // Attempt to connect to the Read Replica
                DbConnection readConn = CreateConnection(ReadConnectionName);

                // We open the connection here briefly to test if the replica is actually alive.
                // Npgsql connection pooling makes this operation very fast.
                readConn.Open();
                readConn.Close();

                return readConn;
            }
            catch (Exception ex)
            {
                // LOG THIS EXCEPTION (e.g., using NLog or log4net)
                System.Diagnostics.Trace.TraceWarning("Read replica failed. Falling back to primary. Error: " + ex.Message);

                // Failover: If the read replica fails, fallback to the primary DB so the app doesn't crash.
                return CreateDefaultConnection();
            }
        }

        private static bool IsRdsEnvironmentConfigured()
        {
            List<string> missingVariables = new List<string>();
            int configuredVariableCount = 0;

            foreach (string variableName in RdsEnvironmentVariableNames)
            {
                if (string.IsNullOrWhiteSpace(GetEnvironmentValue(variableName)))
                {
                    missingVariables.Add(variableName);
                }
                else
                {
                    configuredVariableCount++;
                }
            }

            if (configuredVariableCount == 0)
            {
                return false;
            }

            if (missingVariables.Count > 0)
            {
                throw new ConfigurationErrorsException(
                    "RDS database configuration is incomplete. Missing environment variables: "
                    + string.Join(", ", missingVariables)
                    + ".");
            }

            return true;
        }

        private static DbConnection CreateRdsConnection()
        {
            int port;
            string portValue = GetEnvironmentValue("ONYX_DB_PORT");

            if (!int.TryParse(portValue, out port) || port < 1 || port > 65535)
            {
                throw new ConfigurationErrorsException("ONYX_DB_PORT must be a valid TCP port number.");
            }

            NpgsqlConnectionStringBuilder builder = new NpgsqlConnectionStringBuilder
            {
                Host = GetEnvironmentValue("ONYX_DB_HOST"),
                Port = port,
                Database = GetEnvironmentValue("ONYX_DB_NAME"),
                Username = GetEnvironmentValue("ONYX_DB_USER"),
                Password = GetEnvironmentValue("ONYX_DB_PASSWORD"),
                SslMode = SslMode.Require,
                TrustServerCertificate = true,
                Pooling = true,
                MinPoolSize = 1,
                MaxPoolSize = 100,
                KeepAlive = 30
            };

            return new NpgsqlConnection(builder.ConnectionString);
        }

        private static string GetEnvironmentValue(string variableName)
        {
            string value = Environment.GetEnvironmentVariable(variableName);

            if (string.IsNullOrWhiteSpace(value))
            {
                value = Environment.GetEnvironmentVariable(variableName, EnvironmentVariableTarget.User);
            }

            return value;
        }

        private static DbConnection CreateConnection(string connectionName)
        {
            ConnectionStringSettings settings = ConfigurationManager.ConnectionStrings[connectionName];

            if (settings == null || string.IsNullOrWhiteSpace(settings.ConnectionString))
            {
                throw new ConfigurationErrorsException("Missing connection string: " + connectionName + ". Ensure it is defined in Web.config.");
            }

            if (settings.ConnectionString.Contains("<") || settings.ConnectionString.Contains(">"))
            {
                throw new ConfigurationErrorsException("Connection string " + connectionName + " contains unresolved placeholder values.");
            }

            // Using NpgsqlFactory directly is often safer and more performant when strictly using PostgreSQL,
            // rather than relying on the machine.config registration of DbProviderFactories.
            DbProviderFactory factory;
            try
            {
                factory = DbProviderFactories.GetFactory(settings.ProviderName);
            }
            catch (ArgumentException)
            {
                // Fallback: If DbProviderFactories fails to find the provider (common deployment issue), 
                // explicitly use Npgsql if the provider name matches.
                if (settings.ProviderName.Equals("Npgsql", StringComparison.OrdinalIgnoreCase))
                {
                    factory = NpgsqlFactory.Instance;
                }
                else
                {
                    throw;
                }
            }

            DbConnection connection = factory.CreateConnection();

            if (connection == null)
            {
                throw new InvalidOperationException("Could not create a database connection for provider " + settings.ProviderName + ".");
            }

            connection.ConnectionString = settings.ConnectionString;
            return connection;
        }
    }
}
