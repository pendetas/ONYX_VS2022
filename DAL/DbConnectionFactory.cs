using System;
using System.Configuration;
using System.Data.Common;

namespace ONYX_DDAC.DAL
{
    public class DbConnectionFactory
    {
        private const string DefaultConnectionName = "DefaultConnection";
        private const string ReadConnectionName = "ReadConnection";

        public DbConnection CreateDefaultConnection()
        {
            return CreateConnection(DefaultConnectionName);
        }

        public DbConnection CreateReadConnection()
        {
            ConnectionStringSettings readConnection = ConfigurationManager.ConnectionStrings[ReadConnectionName];
            return readConnection == null ? CreateConnection(DefaultConnectionName) : CreateConnection(ReadConnectionName);
        }

        private static DbConnection CreateConnection(string connectionName)
        {
            ConnectionStringSettings settings = ConfigurationManager.ConnectionStrings[connectionName];

            if (settings == null)
            {
                throw new ConfigurationErrorsException("Missing connection string: " + connectionName + ".");
            }

            if (settings.ConnectionString.IndexOf("<", StringComparison.Ordinal) >= 0 ||
                settings.ConnectionString.IndexOf(">", StringComparison.Ordinal) >= 0)
            {
                throw new ConfigurationErrorsException("Connection string " + connectionName + " still contains placeholder values.");
            }

            DbProviderFactory factory = DbProviderFactories.GetFactory(settings.ProviderName);
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
