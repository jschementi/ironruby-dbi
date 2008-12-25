module DBI
  module DBD
    module ADO
      
      VERSION          = "0.1"
      USED_DBD_VERSION = "0.1"
      FACTORIES        = {
                            :odbc => "OdbcFactory",
                            :oledb => "OleDbFactory",
                            :oracle => "OracleClientFactory",
                            :mssql => "SqlClientFactory",
                            :sqlce => "SqlCeProviderFactory",
                            :mysql => "MySqlClientFactory",
                            :sqlite => "SQLiteFactory"
                         }
      
      class Driver < DBI::BaseDriver
        
        def initialize
          super(USED_DBD_VERSION)
        end
        
        def connect(dbname, user, auth, attr)
          # connect to database
          
          handle = SqlConnection.new('ADODB.Connection')
          handle.Open(dbname)
          handle.BeginTrans()  # start new Transaction
          
          return Database.new(handle, attr)
        rescue RuntimeError => err
          raise DBI::DatabaseError.new(err.message)
        end
        
      end