#region Usings

using System;
using System.Data.Common;

#endregion

namespace IronRuby.DBD
{
    public class DbdDriver : IDbdDriver
    {
        public const string DEFAULT_PROVIDER = "System.Data.SqlClient";

        private DbProviderFactory _factory;

        public DbdDriver(string providerName)
        {
            LoadFactory(providerName);
        }

        #region IDbdDriver Members

        public IDbdDatabase Connect(string connectionString)
        {
            var conn = _factory.CreateConnection();
            conn.ConnectionString = connectionString;

            conn.Open();
            var trans = conn.BeginTransaction();

            return new DbdDatabase(trans);
        }

        #endregion

        private void LoadFactory(string providerName)
        {
            if (_factory != null) return;

            var factory = DbProviderFactories.GetFactory(string.IsNullOrEmpty(providerName) ? DEFAULT_PROVIDER : providerName);

            if (factory == null)
                throw new NotSupportedException();

            _factory = factory;
        }
    }
}