module DBI
  module DBD
    module MSSQL

      class Database < DBI::BaseDatabase
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

        def initialize(dbd_db, attr)
          super
          @attr['AutoCommit'] = true
        end

        def disconnect
          @trans.rollback unless @trans.nil? && @attr['AutoCommit']
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

        def tables
          @handle.get_schema("Tables").rows.collect { |row| row["TABLE_NAME"].to_s }
        rescue RuntimeError => err
          raise DBI::DatabaseError.new(err.message)
        end

        def transaction
          @trans
        end

        def has_transaction?
          !@trans.nil?
        end

        def columns(table)
          sql = "select object_name(c.object_id) as table_name, c.column_id, c.name, type_name(system_type_id) as sql_type,
              max_length, is_nullable, precision, scale, object_definition(c.default_object_id) as default_value,
              convert(bit,(Select COUNT(*) from sys.indexes as i
                inner join sys.index_columns as ic
                  on ic.index_id = i.index_id and ic.object_id = i.object_id
                inner join sys.columns as c2 on ic.column_id = c2.column_id and i.object_id = c2.object_id
              WHERE i.is_primary_key = 1 and ic.column_id = c.column_id and i.object_id=c.object_id)) as is_primary_key,               
              convert(bit,(Select COUNT(*) from sys.indexes as i
                inner join sys.index_columns as ic
                  on ic.index_id = i.index_id and ic.object_id = i.object_id
                inner join sys.columns as c2 on ic.column_id = c2.column_id and i.object_id = c2.object_id
              WHERE i.is_primary_key = 0
                and i.is_unique_constraint = 0 and ic.column_id = c.column_id and i.object_id=c.object_id)) as is_index,
              convert(bit,(Select Count(*) from sys.indexes as i inner join sys.index_columns as ic
                  on ic.index_id = i.index_id and ic.object_id = i.object_id
                inner join sys.columns as c2 on ic.column_id = c2.column_id and i.object_id = c2.object_id
              WHERE (i.is_unique_constraint = 1) and ic.column_id = c.column_id and i.object_id=c.object_id)) as is_unique
              from sys.columns as c
              WHERE object_name(c.object_id) = @table_name
              order by table_name"
          stmt = prepare(sql)
          stmt.bind_param("table_name", table)
          stmt.execute
          ret = stmt.fetch_all.collect do |row|
            ColumnInfo.new({
                    :name => row[2].to_s,
                    :sql_type => SQL_TYPE_NAMES[row[3].upcase.to_sym],
                    :type_name => CLR_TYPES[row[3].upcase.to_sym],
                    :precision => row[6].zero? ? row[4] : row[6],
                    :default => row[8],
                    :scale => row[7],
                    :nullable => row[5],
                    :primary => row[9],
                    :indexed => row[10],
                    :unique => row[11]
            })
          end
          stmt.finish
          ret
        end

        def commit
          #self.do("COMMIT") unless @attr['AutoCommit']
          unless @attr['AutoCommit']
            @trans.commit if @trans
            @trans = @handle.begin_transaction
          end
        rescue RuntimeError => err
          raise DBI::DatabaseError.new(err.message)
        end

        def rollback
          unless @attr['AutoCommit']
            @trans.rollback if @trans
            @trans = @handle.begin_transaction
          end
        rescue RuntimeError => err
          raise DBI::DatabaseError.new(err.message)
        end

        def do(stmt, bindvars={})
          st = prepare(stmt)
          bindvars.each { |k, v| st.bind_param(k, v) }
          res = st.execute
          st.finish
          return res
        rescue RuntimeError => err
          raise DBI::DatabaseErrro.new(err.message)
        end

        def current_connection
          @handle
        end

        def []=(attr, value)
          if attr == 'AutoCommit' and @attr[attr] != value

            self.commit if value
            @trans.rollback unless @trans.nil?
            @trans = nil
          end
          @attr[attr] = value
        end

      end # class Database
    end
  end
end