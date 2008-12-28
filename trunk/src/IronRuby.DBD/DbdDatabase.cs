#region Usings

using System.Data;

#endregion

namespace IronRuby.DBD
{
    public class DbdDatabase : IDbdDatabase
    {
        private readonly IDbConnection _connection;
        private readonly IDbTransaction _transaction;

        public DbdDatabase(IDbTransaction transaction)
        {
            _connection = transaction.Connection;
            _transaction = transaction;
        }

        #region IDbdDatabase Members

        public void Disconnect()
        {
            _transaction.Rollback();
            _connection.Close();
        }

        public IDbdStatement Prepare(string statement)
        {
            return new DbdStatement(statement, _connection, _transaction);
        }

        public bool Ping()
        {
            var cmd = _connection.CreateCommand();
            cmd.CommandText = "Select 1";
            try
            {
                cmd.ExecuteNonQuery();
                return true;
            }
            catch
            {
                return false;
            }
        }

        #endregion

        public void Commit()
        {
            _transaction.Commit();
            _connection.BeginTransaction();
        }

        public void RollBack()
        {
            _transaction.Rollback();
            _connection.BeginTransaction();
        }
    }
}