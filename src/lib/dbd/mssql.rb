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

      CLR_TYPES = {
                :INTEGER => "int",
                :DOUBLE => "double",
                :LONGVARCHAR => "string",
                :DATE => "DateTime",
                :TIME => "DateTime",
                :TIMESTAMP => "DateTime",
                :BINARY => "byte[]",
                :LONGVARBINARY => "byte[]",
                :BLOB => "byte[]",
                :CLOB => "byte[]",
                :OTHER => "",
                :BOOLEAN => "bool",
                :UNIQUEIDENTIFIER => "Guid",
                :TINYINT => "byte",
                :SMALLINT => "short",
                :BIGINT => "long",
                :INT => "int",
                :FLOAT => "double",
                :REAL => "float",
                :SMALLMONEY => "decimal",
                :MONEY => "decimal",
                :NUMERIC => "decimal",
                :DECIMAL => "decimal",
                :BIT => "bool",
                :UNIQUEIDENTIFIER => "Guid",
                :VARCHAR => "string",
                :NVARCHAR => "string",
                :TEXT => "string",
                :NTEXT => "string",
                :CHAR => "char",
                :NCHAR => "char",
                :VARBINARY => "byte[]",
                :IMAGE => "byte[]",
                :DATETIME => "DateTime"
        }

        SQL_TYPE_NAMES = {
                :BIT => "BIT",
                :TINYINT => "TINYINT",
                :SMALLINT => "SMALLINT",
                :INTEGER => "INTEGER",
                :INT => "INTEGER",
                :BIGINT => "BIGINT",
                :FLOAT => "FLOAT",
                :REAL => "REAL",
                :DOUBLE => "DOUBLE",
                :NUMERIC => "NUMERIC",
                :DECIMAL => "DECIMAL",
                :CHAR => "CHAR",
                :NCHAR => "CHAR",
                :VARCHAR => "VARCHAR",
                :NVARCHAR => "VARCHAR",
                :LONGVARCHAR => "LONG VARCHAR",
                :TEXT => "LONG VARCHAR",
                :NTEXT => "LONG VARCHAR",
                :DATE => "DATE",
                :DATETIME => "DATETIME",
                :TIME => "TIME",
                :TIMESTAMP => "TIMESTAMP",
                :BINARY => "BINARY",
                :VARBINARY => "VARBINARY",
                :LONGVARBINARY => "LONG VARBINARY",
                :IMAGE => "BLOB",
                :BLOB => "BLOB",
                :CLOB => "CLOB",
                :OTHER => "",
                :BOOLEAN => "BOOLEAN",
                :UNIQUEIDENTIFIER => "VARCHAR"
        }

    end
  end
end

require File.dirname(__FILE__) + "/mssql/driver"
require File.dirname(__FILE__) + "/mssql/database"
require File.dirname(__FILE__) + "/mssql/statement"