#region Usings

using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using System.Diagnostics;

#endregion

namespace IronRuby.DBD
{
    public class DbdStatement //: IDbdStatement
    {
        public static readonly Dictionary<string, string> CLR_TYPES = new Dictionary<string, string>
                                                                          {
                                                                              {"TINYINT", "byte"},
                                                                              {"SMALLINT", "short"},
                                                                              {"BIGINT", "long"},
                                                                              {"INT", "int"},
                                                                              {"FLOAT", "double"},
                                                                              {"REAL", "float"},
                                                                              {"SMALLMONEY", "decimal"},
                                                                              {"MONEY", "decimal"},
                                                                              {"NUMERIC", "decimal"},
                                                                              {"DECIMAL", "decimal"},
                                                                              {"BIT", "bool"},
                                                                              {"UNIQUEIDENTIFIER", "Guid"},
                                                                              {"VARCHAR", "string"},
                                                                              {"NVARCHAR", "string"},
                                                                              {"TEXT", "string"},
                                                                              {"NTEXT", "string"},
                                                                              {"CHAR", "char"},
                                                                              {"NCHAR", "char"},
                                                                              {"VARBINARY", "byte[]"},
                                                                              {"IMAGE", "byte[]"},
                                                                              {"DATETIME", "DateTime"}
                                                                          };

        public static readonly Dictionary<string, string> SQL_TYPE_NAMES = new Dictionary<string, string>
                                                                               {
                                                                                   {"BIT", "BIT"},
                                                                                   {"TINYINT", "TINYINT"},
                                                                                   {"SMALLINT", "SMALLINT"},
                                                                                   {"INTEGER", "INTEGER"},
                                                                                   {"INT", "INTEGER"},
                                                                                   {"BIGINT", "BIGINT"},
                                                                                   {"FLOAT", "FLOAT"},
                                                                                   {"REAL", "REAL"},
                                                                                   {"DOUBLE", "DOUBLE"},
                                                                                   {"NUMERIC", "NUMERIC"},
                                                                                   {"DECIMAL", "DECIMAL"},
                                                                                   {"CHAR", "CHAR"},
                                                                                   {"NCHAR", "CHAR"},
                                                                                   {"VARCHAR", "VARCHAR"},
                                                                                   {"NVARCHAR", "VARCHAR"},
                                                                                   {"LONGVARCHAR", "LONG VARCHAR"},
                                                                                   {"TEXT", "LONG VARCHAR"},
                                                                                   {"NTEXT", "LONG VARCHAR"},
                                                                                   {"DATE", "DATE"},
                                                                                   {"DATETIME", "DATETIME"},
                                                                                   {"TIME", "TIME"},
                                                                                   {"TIMESTAMP", "TIMESTAMP"},
                                                                                   {"BINARY", "BINARY"},
                                                                                   {"VARBINARY", "VARBINARY"},
                                                                                   {"LONGVARBINARY", "LONG VARBINARY"},
                                                                                   {"IMAGE", "BLOB"},
                                                                                   {"CLOB", "CLOB"},
                                                                                   {"OTHER", string.Empty},
                                                                                   {"BOOLEAN", "BOOLEAN"},
                                                                                   {"UNIQUEIDENTIFIER", "VARCHAR"}
                                                                               };

        private readonly IDbCommand _command;
        private readonly IDbConnection _connection;
        private DataTable _schema;
        private int _currentIndex;
        private List<object[]> _rows;
        private int _recordsAffected;

        public DbdStatement(string statement, IDbConnection connection, IDbTransaction transaction)
        {
            _connection = connection;
            _command = _connection.CreateCommand();
            _command.CommandText = statement;
            _command.Transaction = transaction;
        }

        #region IDbdStatement Members

        public void BindParam(string param, object value, IDictionary<string, object> attribs)
        {
            var parameter = _command.CreateParameter();
            parameter.ParameterName = param;
            parameter.Value = value;
            _command.Parameters.Add(parameter);
        }

        public void Execute()
        {
            _currentIndex = 0;
            _rows = new List<object[]>();
            if(ConnectionState.Open != _command.Connection.State) _command.Connection.Open();
            using(var reader = _command.ExecuteReader())
            {
                
                _schema = reader.GetSchemaTable();
                _recordsAffected = reader.RecordsAffected;
                while (reader.Read())
                {
                    _rows.Add(ReadRow(reader));
                }
            }
        }

        public void Finish()
        {
//            _reader.Close();
            _command.Dispose();
            _connection.Close();
        }

        /// <summary>
        /// Fetches the current row. Returns an Array containing all column data or nil if the last column has been read.
        /// </summary>
        /// <returns></returns>
        public object[] Fetch()
        {
            return _currentIndex < _rows.Count - 1 ? _rows[_currentIndex++] : null;
        }

        /// <summary>
        /// Returns an Array of Hash objects, one for each column.
        /// Each Hash object must have at least one key 'name' which value is the name of that column.
        /// Further possible values are
        /// 'sql_type' (integer, e.g., DBI::SQL_INT),
        /// 'type_name' (string), 
        /// 'precision' (= column size),
        /// 'scale' (= decimal digits),
        /// 'default',
        /// 'nullable',
        /// 'indexed',
        /// 'primary',
        /// 'unique'.
        /// </summary>
        /// <returns></returns>
        public IDictionary<string, object>[] ColumnInfo()
        {
//            GetSchema();
            var result = new List<Dictionary<string, object>>(_schema.Columns.Count);

            foreach (DataRow row in _schema.Rows)
            {
                var colInfo = new Dictionary<string, object>();
                var colName = row["ColumnName"].ToString();
                var dataTypeName = row["DataTypeName"].ToString();
                colInfo["name"] = colName;
                Debug.WriteLine(string.Format("Data type: {0}", dataTypeName));
                colInfo["sql_type"] = SQL_TYPE_NAMES[dataTypeName.ToUpperInvariant()];
                colInfo["type_name"] = CLR_TYPES[dataTypeName.ToUpperInvariant()];
                colInfo["precision"] = row["NumericPrecision"];
                colInfo["scale"] = row["NumericScale"];
//                colInfo["default"] = row["DefaultValue"];
                colInfo["nullable"] = row["AllowDBNull"];
                //colInfo["indexed"] = row["IsIndex"];
                colInfo["primary"] = IsPrimaryKey(colName);
                colInfo["unique"] = row["IsUnique"];
                result.Add(colInfo);
            }

            return result.ToArray();
        }

        public int Rows()
        {
            return _recordsAffected;
        }

        #endregion

//        private object[] ReadRow()
//        {
//            return ReadRow(_reader);
//        }

        private object[] ReadRow(IDataRecord reader)
        {
            var info = ColumnInfo();
            var results = new object[info.Length];
            //if (_results == null || _results.Length != info.Length)
            //    _results = new object[info.Length];

            for (var i = 0; i < info.Length; i++)
            {
                results[i] = reader[i];
            }
            return results;
        }

//        private void GetSchema()
//        {
//            if (_schema == null)
//                _schema = _reader.GetSchemaTable();
//        }

        private bool IsPrimaryKey(string columnName)
        {
            var pk = _schema.PrimaryKey;
            foreach (var column in pk)
            {
                if (column.ColumnName == columnName)
                    return true;
            }
            return false;
        }

        public static string ToDbiType(string dataType)
        {
            return SQL_TYPE_NAMES[dataType.ToUpperInvariant()];
        }

        public static string ToClrType(string dataType)
        {
            return CLR_TYPES[dataType.ToUpperInvariant()];
        }

        public static object GetRowValue(DataRow row, string key)
        {
            return row[key];
        }

        public static object GetReaderValue(IDataRecord record, int index)
        {
            return record[index];
        }

        public static object GetRecordValue(IDataRecord record, string name)
        {
            return record[name];
        }
    }
}