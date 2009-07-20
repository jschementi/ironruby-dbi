module DBI
  module DBD
    module ADONET

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
          @statement = @command.command_text = statement
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