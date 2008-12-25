#region Usings

using System.Collections.Generic;
using System.Data;

#endregion

namespace IronRuby.DBD
{
    public class DbdStatement : IDbdStatement
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
                                                                                   {"BIGINT", "BIGINT"},
                                                                                   {"FLOAT", "FLOAT"},
                                                                                   {"REAL", "REAL"},
                                                                                   {"DOUBLE", "DOUBLE"},
                                                                                   {"NUMERIC", "NUMERIC"},
                                                                                   {"DECIMAL", "DECIMAL"},
                                                                                   {"CHAR", "CHAR"},
                                                                                   {"VARCHAR", "VARCHAR"},
                                                                                   {"LONGVARCHAR", "LONG VARCHAR"},
                                                                                   {"DATE", "DATE"},
                                                                                   {"TIME", "TIME"},
                                                                                   {"TIMESTAMP", "TIMESTAMP"},
                                                                                   {"BINARY", "BINARY"},
                                                                                   {"VARBINARY", "VARBINARY"},
                                                                                   {"LONGVARBINARY", "LONG VARBINARY"},
                                                                                   {"IMAGE", "BLOB"},
                                                                                   {"CLOB", "CLOB"},
                                                                                   {"OTHER", string.Empty},
                                                                                   {"BOOLEAN", "BOOLEAN"},
                                                                               };

        private readonly IDbCommand _command;
        private readonly IDbConnection _connection;
        private IDataReader _reader;
        private object[] _results;
        private DataTable _schema;

        public DbdStatement(string statement, IDbConnection connection)
        {
            _connection = connection;
            _command = _connection.CreateCommand();
            _command.CommandText = statement;
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
            _reader = _command.ExecuteReader();
        }

        public void Finish()
        {
            _command.Dispose();
            _connection.Close();
        }

        /// <summary>
        /// Fetches the current row. Returns an Array containing all column data or nil if the last column has been read.
        /// </summary>
        /// <returns></returns>
        public object[] Fetch()
        {
            return _reader.Read() ? ReadRow() : null;
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
            GetSchema();
            var result = new List<Dictionary<string, object>>(_schema.Columns.Count);

            foreach (DataRow row in _schema.Rows)
            {
                var colInfo = new Dictionary<string, object>();
                var colName = row["ColumnName"].ToString();
                colInfo["name"] = colName;
                colInfo["sql_type"] = SQL_TYPE_NAMES[row["DataTypeName"].ToString().ToUpperInvariant()];
                colInfo["type_name"] = CLR_TYPES[row["DataTypeName"].ToString().ToLowerInvariant()];
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
            return _reader.RecordsAffected;
        }

        #endregion

        private object[] ReadRow()
        {
            return ReadRow(_reader);
        }

        private object[] ReadRow(IDataReader reader)
        {
            var info = ColumnInfo();

            if (_results == null || _results.Length != info.Length)
                _results = new object[info.Length];

            for (var i = 0; i < info.Length; i++)
            {
                _results[i] = _reader[i];
            }

            return _results;
        }

        private void GetSchema()
        {
            if (_schema == null)
                _schema = _reader.GetSchemaTable();
        }

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

        protected virtual string ToDbiType(string dataType)
        {
            return SQL_TYPE_NAMES[dataType.ToUpperInvariant()];
        }

        protected virtual string ToClrType(string dataType)
        {
            return CLR_TYPES[dataType.ToUpperInvariant()];
        }
    }
}