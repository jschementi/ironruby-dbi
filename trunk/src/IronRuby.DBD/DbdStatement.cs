#region Usings

using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using System.Diagnostics;

#endregion

namespace IronRuby.DBD
{
    public class DbdStatement 
    {
        public static object GetRowValue(DataRow row, string key)
        {
            return row[key];
        }

        public static object GetDefaultValue(DataRow row, string key)
        {
            var table = row.Table;
            var col = table.Columns[key];
            return col == null ? null : col.DefaultValue;
        }

    }
}