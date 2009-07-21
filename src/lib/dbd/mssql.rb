require 'dbi'

module DBI
  module DBD



    module MSSQL
      
      VERSION          = "0.2"
      USED_DBD_VERSION = "0.4.0"
      DESCRIPTION      = "ADO.NET Microsoft SQL Server DBI DBD"
                 
      def self.driver_name
        "MsSql"
      end

    end
  end
end

require File.dirname(__FILE__) + "/mssql/driver"
require File.dirname(__FILE__) + "/mssql/database"
require File.dirname(__FILE__) + "/mssql/statement"