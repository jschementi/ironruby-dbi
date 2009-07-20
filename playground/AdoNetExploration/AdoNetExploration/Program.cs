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
            var dt = conn.GetSchema("tables", new []{null, null, null, "BASE TABLE"});
           
            foreach (DataRow row in dt.Rows)
            {
                var sb = new StringBuilder();
                foreach (DataColumn col in dt.Columns)
                {
                    sb.AppendFormat("{0}: {1}", col.ColumnName, row[col]);
                }
                sb.Append(Environment.NewLine + "=======" + Environment.NewLine);
                Console.WriteLine(sb.ToString());
            }
            conn.Close();
        }
    }
}
