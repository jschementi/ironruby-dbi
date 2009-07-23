module DBI
  module DBD
    module MSSQL

      class Statement < DBI::BaseStatement

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
          @connection = db.current_connection;
          @command = @connection.create_command
          @statement = statement.to_s
          @command.command_text = @statement.to_clr_string
          @command.transaction = db.current_transaction if db.has_transaction?
          @current_index = 0
          @db = db
        end

        def bind_param(name, value, attribs={})
          unless name.to_s.empty?
            parameter = @command.create_parameter
            parm_name = name.to_s.to_clr_string
            parameter.ParameterName = parm_name
            parameter.Value = value.is_a?(String) ? value.to_clr_string : value

            if @command.parameters.contains(parm_name)
              @command.parameters[parm_name] = parameter
            else
              @command.parameters.add parameter
            end                                            
          end
        end

        def execute
          @current_index = 0
          @rows = []
          @schema = nil
          @reader = @command.execute_reader
          schema

          unless SQL.query?(@statement.to_s)
            finish
          end           
          @reader.records_affected
        rescue RuntimeError => err
          raise DBI::DatabaseError.new(err.message)
        end

        def fetch
          res = @reader.read ? read_row(@reader) : nil
          res
        rescue RuntimeError => err
          raise DBI::DatabaseError.new(err.message)
        end

        def finish
          @reader.close if @reader and not @reader.is_closed
          
        rescue RuntimeError => err
          raise DBI::DatabaseError.new(err.message)
        end

        def cancel
          @command.cancel
        end

        def schema

          @schema ||= @reader.get_schema_table || System::Data::DataTable.new
        end

        def column_info
          infos = schema.rows.collect do |row|
            name = row["ColumnName"]
            def_val_col = row.table.columns[name]
            def_val = def_val_col.nil? ? nil : def_val_col.default_value
            dtn = row["DataTypeName"].to_s
            {

                'name' => name.to_s,
                'dbi_type' => MSSQL_TYPEMAP[dtn.upcase],
                'mssql_type_name' => dtn.upcase,
                'sql_type' =>MSSQL_TO_XOPEN[dtn.upcase][0],
                'type_name' => DBI::SQL_TYPE_NAMES[MSSQL_TO_XOPEN[dtn.upcase][0]],
                'precision' => %w(varchar nvarchar char nchar text ntext).include?(dtn.downcase) ? row["ColumnSize"] : row["NumericPrecision"],
                'default' => def_val,
                'scale' => %w(varchar nvarchar char nchar text ntext).include?(dtn.downcase) ? nil : row["NumericScale"]  ,
                'nullable' => row["AllowDBNull"],
                'primary' => schema.primary_key.select { |pk| pk.column_name.to_s == name.to_s }.size > 0,
                'unique' => row["IsUnique"]
            }
          end 
          infos
        rescue RuntimeError => err
          raise DBI::DatabaseError.new(err.message)
        end

        def rows
          return 0 if @reader.nil?
          res = @reader.records_affected
          res == -1 ? 0 : res
        end

        private

        def read_row(record)
          #(0...schema.rows.count).collect do |i|
          (0...record.visible_field_count).collect do |i|
            res = record.get_value(i)
            case res
            when System::Guid
              res.to_string.to_s
            when System::DBNull
              nil
            when System::Boolean
              res.to_string.to_s
            #elsif res.is_a? System::String
            #  res.to_s
            else
              res.to_s
            end
          end
        end

      end
    end
  end
end