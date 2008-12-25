using System.Data.Common;
using System.Data;
using System.Security.Permissions;

namespace IronRuby.DBD
{
    public interface IDbdProviderFactory
    {
       
        DbConnectionStringBuilder CreateConnectionStringBuilder();
        DbConnection CreateConnection();
        DbParameter CreateParameter();

        DbCommandBuilder CreateCommandBuilder();
        DbDataAdapter CreateDataAdapter();
        DbDataSourceEnumerator CreateDataSourceEnumerator();
        DbParameter CreatePermission(PermissionState st);
    }
    public class DbdProviderFactory 
    {
    }
}