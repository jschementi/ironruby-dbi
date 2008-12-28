using System;
using System.Collections.Generic;
using System.Data;
using System.Data.Common;
using System.Linq;
using System.Text;

namespace IronRuby.DBD.Interop
{
    class Program
    {
        static void Main(string[] args)
        {
            var dt = DbProviderFactories.GetFactoryClasses();
            foreach (DataColumn o in dt.Columns)
            {
                Console.WriteLine(o.ColumnName);
            }

            Console.WriteLine("=================");
            Console.WriteLine("    Rows      ");
            Console.WriteLine("=================");

            foreach(DataRow factory in dt.Rows)
            {
                Console.WriteLine(factory["InvariantName"]);
//                Console.WriteLine(DbProviderFactories.GetFactory(factory["InvariantName"].ToString()).GetType().Name);
            }
//            var fact = DbProviderFactories.GetFactory("System.Data.SqlClient");
//            Console.WriteLine("Provider name: {0}", fact.GetType().Name);
        }
    }
}
