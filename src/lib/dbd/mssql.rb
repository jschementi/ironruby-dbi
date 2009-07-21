require 'dbi'
require 'System.Data'

module DBI
  module DBD

    PROVIDERS = {
        :odbc => "System.Data.Odbc",
        :oledb => "System.Data.OleDb",
        :oracle => "System.Data.OracleClient",
        :mssql => "System.Data.SqlClient",
        :sqlce => "System.Data.SqlServerCe.3.5",
        :mysql => "MySql.Data.MySqlClient",
        :sqlite => "System.Data.SQLite"
      }

    module MSSQL
      
      VERSION          = "0.2"
      USED_DBD_VERSION = "0.4.0"
      DESCRIPTION      = "ADO.NET Microsoft SQL Server DBI DBD"


      PROVIDERS        = {
        :odbc => "System.Data.Odbc",
        :oledb => "System.Data.OleDb",
        :oracle => "System.Data.OracleClient",
        :mssql => "System.Data.SqlClient",
        :sqlce => "System.Data.SqlServerCe.3.5",
        :mysql => "MySql.Data.MySqlClient",
        :sqlite => "System.Data.SQLite"
      }

      def self.driver_name
        "MsSql"
      end

      



    end
  end
end

require File.dirname(__FILE__) + "/mssql/driver"
require File.dirname(__FILE__) + "/mssql/database"
require File.dirname(__FILE__) + "/mssql/statement"