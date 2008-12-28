require 'mscorlib'
require 'System, Version=2.0.0.0, Culture=neutral, PublicKeyToken=b77a5c561934e089'
require 'System.Data, Version=2.0.0.0, Culture=neutral, PublicKeyToken=b77a5c561934e089'
require 'IronRuby.DBD, Version=1.0.0.0, Culture=neutral, PublicKeyToken=null'

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
        include IronRuby::DBD
        
        def initialize
          super(USED_DBD_VERSION)
        end
        
        def connect(driver_url, user, auth, attr)
          provider, connection = parse_connection_string(driver_url)
          load_factory PROVIDERS[provider.to_sym]
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
          #clr_stmt = DbdStatement.new(statement, @handle);
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
        
      end # class Database
      
      class Statement < DBI::BaseStatement
        include IronRuby::DBD
        
        def initialize(statement, db)
          @connection = db.current_connection;
          @command = @connection.create_command
          @command.command_text = statement
          @command.transaction = db.current_transaction
          @current_index = 0
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
            name = DbdStatement.get_row_value row, "ColumnName"
            dtn = DbdStatement.get_row_value row, "DataTypeName"
            info = {
              :name => name,
              :sql_type => DbdStatement.to_dbi_type(dtn),
              :type_name => DbdStatement.to_clr_type(dtn),
              :precision => DbdStatement.get_row_value(row, "NumericPrecision"),
              :scale => DbdStatement.get_row_value(row, "NumericScale"),
              :nullable => DbdStatement.get_row_value(row, "AllowDBNull"),
              :primary => schema.primary_key.select { |pk| pk.column_name.to_s == name.to_s }.size > 0,
              :unique => DbdStatement.get_row_value(row, "IsUnique")
            }
            info
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
          (0...schema.columns.count).collect { |i| DbdStatement.get_reader_value(record, i) }
        end
        
      end
      
    end
  end
end