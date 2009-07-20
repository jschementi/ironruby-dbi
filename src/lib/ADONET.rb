require 'mscorlib'
require 'System, Version=2.0.0.0, Culture=neutral, PublicKeyToken=b77a5c561934e089'
require 'System.Data, Version=2.0.0.0, Culture=neutral, PublicKeyToken=b77a5c561934e089'
#require File.dirname(__FILE__) + '/Workarounds.dll'

module DBI
  module DBD
    module ADONET
      
      VERSION          = "0.1"
      USED_DBD_VERSION = "0.1"
      PROVIDERS        = {
        :odbc => "System.Data.Odbc",
        :oledb => "System.Data.OleDb",
        :oracle => "System.Data.OracleClient",
        :mssql => "System.Data.SqlClient",
        :sqlce => "System.Data.SqlServerCe.3.5",
        :mysql => "MySql.Data.MySqlClient",
        :sqlite => "System.Data.SQLite"
      }
      
      class Driver < DBI::BaseDriver
        
        include System::Data::Common
        
        def initialize
          super(USED_DBD_VERSION)
        end
        
        def connect(driver_url, user, auth, attr)
          provider, connection = parse_connection_string(driver_url)
          load_factory PROVIDERS[provider.downcase.to_sym]
          conn = @factory.create_connection
          conn.connection_string = connection
          conn.open
          
          return Database.new(conn, attr);
          
        rescue RuntimeError => err
          raise DBI::DatabaseError.new(err.message)
        end
        
        private
        
        def parse_connection_string(connection_string)
          if connection_string =~ /^([^:]+)(:(.*))$/ 
            [$1, $3]
          else
            raise InterfaceError, "Invalid provider name"
          end
        end
        
        def load_factory(provider_name)
          return nil if defined? @factory
          
          provider = (provider_name.nil? || provider_name.empty?) ? DEFAULT_PROVIDER : provider_name
          @factory = DbProviderFactories.get_factory provider
        end
        
      end
      
      class Database < DBI::BaseDatabase
        
        def initialize(dbd_db, attr)
          super
          @trans = dbd_db.begin_transaction
        end
        
        def disconnect
          @trans.rollback
          @handle.close
        rescue RuntimeError => err
          raise DBI::DatabaseError.new(err.message)
        end
        
        def prepare(statement)
          Statement.new(statement, self)
        end
        
        def ping
          cmd = @handle.create_command
          cmd.command_text = "Select 1"
          begin
            cmd.execute_non_query
            return true
          rescue
            return false
          end
        rescue RuntimeError => err
          raise DBI::DatabaseError.new(err.message)
        end 
        
        def commit
          @trans.commit
          @trans = @handle.begin_transaction
        rescue RuntimeError => err
          raise DBI::DatabaseError.new(err.message)
        end
        
        def rollback
          @trans.rollback
          @trans = @handle.begin_transaction
        rescue RuntimeError => err
          raise DBI::DatabaseError.new(err.message)
        end       
        
        def current_transaction
          @trans
        end
        
        def current_connection
          @handle
        end
        
        def []=(attr, value)
          if attr == 'AutoCommit' then
            # TODO: commit current transaction?
            @attr[attr] = value
          else
            super
          end
        end
        
      end # class Database
      
      class Statement < DBI::BaseStatement
        include Workarounds
        
        CLR_TYPES = {
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
        
        def initialize(statement, db)
          @statement = statement
          @connection = db.current_connection;
          @command = @connection.create_command
          @command.command_text = statement
          @command.transaction = db.current_transaction
          @current_index = 0
          @db = db
        end 
        
        def bind_param(name, value, attribs)
          parameter = @command.create_parameter
          parameter.ParameterName = name
          parameter.Value = value
          @command.parameters.add parameter
        end 
        
        def execute
          @current_index = 0
          @rows = []
          @schema = nil
          @reader = @command.execute_reader
          
          finish if not SQL.query?(@statement)
          # TODO: SELECT and AutoCommit finishes the result-set
          #       what to do?
          if @db['AutoCommit'] and not SQL.query?(@statement) then
            @db.commit
          end
        rescue RuntimeError => err
          raise DBI::DatabaseError.new(err.message)
        end 
        
        def fetch
          @reader.read ? read_row(@reader) : nil
        rescue RuntimeError => err
          raise DBI::DatabaseError.new(err.message)
        end 
        
        def finish
          @reader.close
          
        rescue RuntimeError => err
          raise DBI::DatabaseError.new(err.message)
        end 
        
        def schema
          @schema ||= @reader.get_schema_table	
        end
        
        def column_info
          
          infos = schema.rows.collect do |row|
            name = row["ColumnName"]
            def_val_col = row.table.columns[name]
            def_val = def_val_col.nil? ? nil : def_val_col.default_value
            dtn = row["DataTypeName"].to_s
            {
              :name => name.to_s,
              :sql_type => SQL_TYPE_NAMES[dtn.upcase.to_sym],
              :type_name => CLR_TYPES[dtn.upcase.to_sym],
              :precision => row["NumericPrecision"],
              :default => def_val,
              :scale => row["NumericScale"],
              :nullable => row["AllowDBNull"],
              :primary => schema.primary_key.select { |pk| pk.column_name.to_s == name.to_s }.size > 0,
              :unique => row["IsUnique"]
            }            
          end
          infos
        rescue RuntimeError => err
          raise DBI::DatabaseError.new(err.message)
        end 
        
        def rows
          return 0 if @reader.nil?
          @reader.records_affected
        end 
        
        private
        
          def read_row(record)
            (0...schema.columns.count).collect do |i| 
              res = record.get_value(i) 
              if res.is_a?(System::Guid)
                res.to_string.to_s
              elsif res.is_a?(System::DBNull)
                nil
              else
                res
              end
            end
          end
        
      end
      
    end
  end
end