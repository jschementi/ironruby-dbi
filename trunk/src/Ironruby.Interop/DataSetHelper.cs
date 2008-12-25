using System;
using System.Collections.Generic;
using System.Data;
using System.Linq;
using System.Text;

namespace Ironruby.Interop
{
    public class DataSetHelper
    {
        public static object GetColumnValue(DataRow row, string columnName)
        {
            return row[columnName];
        }
    }
}
