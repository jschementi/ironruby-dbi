using System;
using System.Collections.Generic;
using System.Data.Common;

namespace IronRuby.DBD
{
    public class DbdDriver : IDbdDriver
    {
        public const string FACTORY_KEY = "factory";
        public const string DEFAULT_PROVIDER = "System.Data.SqlClient";

        private DbProviderFactory _factory;

        public DbdDriver(string factoryName)
        {
            GetFactory(new Dictionary<string, string>{{FACTORY_KEY, factoryName}});
        }

        public IDbdDatabase Connect(string connectionString, string user, string auth, IDictionary<string, string> attr)
        {
            GetFactory(attr);

            var conn = _factory.CreateConnection();
            conn.ConnectionString = connectionString;

            conn.Open();
            var trans = conn.BeginTransaction();

            return new DbdDatabase(trans);
        }

        private void GetFactory(IDictionary<string, string> attr)
        {
            if (_factory != null) return;

            var factoryName = DEFAULT_PROVIDER;
            if (attr.ContainsKey(FACTORY_KEY))
            {
                factoryName = attr[FACTORY_KEY];
                attr.Remove(FACTORY_KEY);
            }
            var factory = DbProviderFactories.GetFactory(factoryName);

            if(factory == null)
                throw new NotSupportedException();

            _factory = factory;
        }
    }
}