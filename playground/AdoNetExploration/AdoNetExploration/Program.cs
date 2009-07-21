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
        private const string schemaQuery = @"select object_name(c.object_id) as table_name, c.column_id, c.name, type_name(system_type_id) as sql_type,
              max_length, is_nullable, precision, scale, object_definition(c.default_object_id) as default_value,
              convert(bit,(Select COUNT(*) from sys.indexes as i
                inner join sys.index_columns as ic
                  on ic.index_id = i.index_id and ic.object_id = i.object_id
                inner join sys.columns as c2 on ic.column_id = c2.column_id and i.object_id = c2.object_id
              WHERE i.is_primary_key = 1 and ic.column_id = c.column_id and i.object_id=c.object_id)) as is_primary_key,               
              convert(bit,(Select COUNT(*) from sys.indexes as i
                inner join sys.index_columns as ic
                  on ic.index_id = i.index_id and ic.object_id = i.object_id
                inner join sys.columns as c2 on ic.column_id = c2.column_id and i.object_id = c2.object_id
              WHERE i.is_primary_key = 0
                and i.is_unique_constraint = 0 and ic.column_id = c.column_id and i.object_id=c.object_id)) as is_index,
              convert(bit,(Select Count(*) from sys.indexes as i inner join sys.index_columns as ic
                  on ic.index_id = i.index_id and ic.object_id = i.object_id
                inner join sys.columns as c2 on ic.column_id = c2.column_id and i.object_id = c2.object_id
              WHERE (i.is_unique_constraint = 1) and ic.column_id = c.column_id and i.object_id=c.object_id)) as is_unique
              from sys.columns as c
              WHERE object_name(c.object_id) = 'users'
              order by table_name";

        static void Main(string[] args)
        {
            var dt = DbProviderFactories.GetFactoryClasses();

            DbConnection conn = new SqlConnection("data source=.;initial catalog=dbitest;user id=sa;password=Password123");
//            conn.Open();
//            var cmd = conn.CreateCommand();
//            cmd.CommandText = schemaQuery;
//            var rdr = cmd.ExecuteReader();
//            var dt = rdr.GetSchemaTable();
            
//            for (int i = 0; i < dt.Rows.Count; i++)
//            {
//                List<string> res = new List<string>();
//                foreach (var o in dt.Rows[i].ItemArray)
//                {
//                    res.Add(o.ToString());
//                }
//                Console.WriteLine(string.Join(", ", res.ToArray()));
//            }
//            conn.Close();
//            Console.WriteLine("# of rows: " + dt.Rows.Count);
//            DataSet ds = new DataSet();
//            var schema = conn.GetSchema();
//
//            foreach (DataRow dataRow in schema.Rows)
//            {
//                ds.Tables.Add(conn.GetSchema(dataRow["CollectionName"].ToString()));
//            }
//            var dt = conn.GetSchema("Indexes");
//            
//            
//            conn.Close();
//            conn.Open();
//
//            var cmd = conn.CreateCommand();
//            cmd.CommandText = "Select top 1 * from names";
//
//            cmd.Parameters.Add(new SqlParameter {ParameterName = "table_name", Value = ""});
//            var rdr = cmd.ExecuteReader(CommandBehavior.SchemaOnly);
//            var sdt = rdr.GetSchemaTable();
//            conn.Close();
            var cmd = conn.CreateCommand();
            cmd.CommandText = "select * from users";// schemaQuery;
            conn.Open();
            var rdr = cmd.ExecuteReader();
                var sb = new StringBuilder();
            while(rdr.Read())
            {
                for(int i=0; i < rdr.VisibleFieldCount; i++)
                {
                    var dtn = rdr.GetDataTypeName(i);
                    sb.AppendFormat("{0}: {1}" + Environment.NewLine, rdr.GetName(i), rdr.GetValue(i)); 
                }
                sb.Append(Environment.NewLine + "=======" + Environment.NewLine);
            }
            Console.WriteLine(sb.ToString());
            conn.Close();
//            foreach (DataRow row in dt.Rows)
//            {
//                //            var row = dt.Rows[0];
//                var sb = new StringBuilder();
//                foreach (DataColumn col in dt.Columns)
//                {
//                    sb.AppendFormat("{0}: {1}" + Environment.NewLine, col.ColumnName, row[col]);
//                }
//                sb.Append(Environment.NewLine + "=======" + Environment.NewLine);
//                Console.WriteLine(sb.ToString());
//            }
             Console.WriteLine("Press any key to exit...");
            Console.ReadKey();
        }
    }
}
