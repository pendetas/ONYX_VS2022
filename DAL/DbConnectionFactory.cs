using System;
using System.Configuration;
using System.Data.Common;
// Ensure you have the Npgsql NuGet package installed
using Npgsql;

namespace ONYX_DDAC.DAL
{
    /// <summary>
    /// Handles creation of database connections, supporting routing between 
    /// the Primary AWS RDS instance (Writes) and the Read Replica (Reads).
    /// </summary>
    public static class DbConnectionFactory
    {
        private const string DefaultConnectionName = "DefaultConnection";
        private const string ReadConnectionName = "ReadConnection";

        /// <summary>
        /// Creates a connection to the primary database. Use this for ALL INSERT, UPDATE, and DELETE operations.
        /// </summary>
        public static DbConnection CreateDefaultConnection()
        {
            return CreateConnection(DefaultConnectionName);
        }

        /// <summary>
        /// Creates a connection to the read replica. Use this for SELECT operations to offload the primary DB.
        /// Includes automatic failover to the primary connection if the replica is unreachable.
        /// </summary>
        public static DbConnection CreateReadConnection()
        {
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
