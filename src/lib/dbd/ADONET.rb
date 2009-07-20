require 'dbi'
require 'System.Data'

module DBI
  module DBD
    module ADONET
      
      VERSION          = "0.2"
      USED_DBD_VERSION = "0.4.0"
      DESCRIPTION      = "ADO.NET DBI DBD"


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
        "ADONET"
      end

      



    end
  end
end

require File.dirname(__FILE__) + "/adonet/driver"
require File.dirname(__FILE__) + "/adonet/database"
require File.dirname(__FILE__) + "/adonet/statement"