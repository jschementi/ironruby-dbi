using System;
using System.Collections.Generic;
using System.Data;
using System.Data.Common;
using System.Data.SqlClient;
using System.Linq;
using System.Text;

namespace AdoNetExploration
{
    class Program
    {
        static void Main(string[] args)
        {
            DbConnection conn = new SqlConnection("data source=.\\SQLExpress;initial catalog=dbitest;user id=sa;password=Password123");
            conn.Open();
//            DataSet ds = new DataSet();
//            var schema = conn.GetSchema();
//
//            foreach (DataRow dataRow in schema.Rows)
//            {
//                ds.Tables.Add(conn.GetSchema(dataRow["CollectionName"].ToString()));
//            }
            var dt = conn.GetSchema("Indexes");
            
            
            conn.Close();
            conn.Open();

            var cmd = conn.CreateCommand();
            cmd.CommandText = "Select top 1 * from names";
            var rdr = cmd.ExecuteReader(CommandBehavior.SchemaOnly);
            var sdt = rdr.GetSchemaTable();
            conn.Close();
            foreach (DataRow row in sdt.Rows)
            {
                //            var row = dt.Rows[0];
                var sb = new StringBuilder();
                foreach (DataColumn col in sdt.Columns)
                {
                    sb.AppendFormat("{0}: {1}" + Environment.NewLine, col.ColumnName, row[col]);
                }
                sb.Append(Environment.NewLine + "=======" + Environment.NewLine);
                Console.WriteLine(sb.ToString());
            }
             Console.WriteLine("Press any key to exit...");
            Console.ReadKey();
        }
    }
}
