using System;
using System.Collections.Generic;

namespace IronRuby.DBD
{
    public interface IStatement
    {
        /// <summary>
        /// Binds the value value to a placeholder. 
        /// The placeholder is represented by param, which is either a String representing the name of the placeholder 
        /// used in the SQL statement 
        /// (e.g., Oracle: "SELECT * FROM EMP WHERE ENAME = :ename") or a Fixnum that indicates the number of the placeholder. 
        /// Placeholder numbers begin at 1.
        /// 
        /// If value is a String, then the default SQL type is VARCHAR or CHAR. 
        /// If value is a Fixnum or Bignum, the default SQL type is INT. 
        /// If value is a Float, the default SQL type is FLOAT.
        /// 
        /// attribs is not yet used in this version but could be a hash containing more information like parameter type, etc.
        /// </summary>
        /// <param name="param">The param.</param>
        /// <param name="value">The value.</param>
        /// <param name="attribs">The attribs.</param>
        void BindParam(string param, object value, IDictionary<string, object> attribs);
        /// <summary>
        /// Executes this statement.
        /// </summary>
        void Execute();
        /// <summary>
        /// Free all the resources for the statement. After calling finish, no other operation on this statement is valid.
        /// </summary>
        void Finish();
        /// <summary>
        /// Fetches the current row. Returns an Array containing all column data or nil if the last column has been read.
        /// </summary>
        /// <returns></returns>
        object[] Fetch();
        /// <summary>
        /// Returns an Array of Hash objects, one for each column. 
        /// Each Hash object must have at least one key 'name' which value is the name of that column. 
        /// Further possible values are 
        ///     'sql_type' (integer, e.g., DBI::SQL_INT), 
        ///     'type_name' (string), 'precision' (= column size), 
        ///     'scale' (= decimal digits), 
        ///     'default', 
        ///     'nullable', 
        ///     'indexed', 
        ///     'primary',
        ///     'unique'.
        /// </summary>
        /// <returns></returns>
        Dictionary<string, object>[] ColumnInfo();
        /// <summary>
        /// Returns the RPC (Row Processed Count) of the last executed statement, or nil if no such exists.
        /// </summary>
        /// <returns></returns>
        int? Rows();
    }

    public interface IDbdDatabase
    {
        /// <summary>
        /// Disconnects from the database.
        /// But you must first roll back all outstanding transactions, so all changes not yet committed get lost (are discarded).
        /// </summary>
        void Disconnect();
        /// <summary>
        /// Prepares the SQL statement.
        /// </summary>
        /// <param name="statement">The statement.</param>
        /// <returns></returns>
        IStatement Prepare(string statement);
        /// <summary>
        /// Pings the database to check whether the connection is alive.
        /// </summary>
        /// <returns></returns>
        bool Ping();
    }

    public interface IDbdDriver
    {
        IDbdDatabase Connect(string connectionString, string user, string auth, IDictionary<string, string> attr);
    }



}