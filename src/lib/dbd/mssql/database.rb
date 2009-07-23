module DBI
  module DBD
    module MSSQL
#
        # Hash to translate MS SQL Server type names to DBI SQL type constants
        #
        # Only used in #mssql_type_info.
        #
        MSSQL_TO_XOPEN = {
            "TINYINT"          => [DBI::SQL_TINYINT, 1, nil],
            "SMALLINT"         => [DBI::SQL_SMALLINT, 2, nil],
            "INT"              => [DBI::SQL_INTEGER, 4, nil],
            "INTEGER"          => [DBI::SQL_INTEGER, 4, nil],
            "BIGINT"           => [DBI::SQL_BIGINT, 8, nil],
            "REAL"             => [DBI::SQL_REAL, 24, nil],
            "FLOAT"            => [DBI::SQL_FLOAT, 12, nil],
            "DECIMAL"          => [DBI::SQL_DECIMAL, 18, nil],
            "NUMERIC"          => [DBI::SQL_DECIMAL, 18, nil],
            "MONEY"            => [DBI::SQL_DECIMAL, 8, 4],
            "SMALLMONEY"       => [DBI::SQL_DECIMAL, 4, 4],
            "DATE"             => [DBI::SQL_DATE, 10, nil],
            "TIME"             => [DBI::SQL_TIME, 8, nil],
            "DATETIME2"        => [DBI::SQL_TIMESTAMP, 19, nil],
            "DATETIME"         => [DBI::SQL_TIMESTAMP, 19, nil],
            "CHAR"             => [DBI::SQL_CHAR, 1, nil],
            "VARCHAR"          => [DBI::SQL_VARCHAR, 255, nil],
            "NCHAR"            => [DBI::SQL_CHAR, 1, nil],
            "NVARCHAR"         => [DBI::SQL_VARCHAR, 255, nil],
            "TEXT"             => [DBI::SQL_VARCHAR, 65535, nil],
            "NTEXT"            => [DBI::SQL_VARCHAR, 131070, nil],
            "BINARY"           => [DBI::SQL_VARBINARY, 65535, nil],
            "VARBINARY"        => [DBI::SQL_VARBINARY, 16277215, nil],
            "IMAGE"            => [DBI::SQL_LONGVARBINARY, 2147483657, nil],
            "BIT"              => [DBI::SQL_BIT, 1, nil],
            "UNIQUEIDENTIFIER" => [DBI::SQL_VARCHAR, 20, nil],
            "XML"              => [DBI::SQL_VARCHAR, 65535, nil],
            "TIMESTAMP"        => [DBI::SQL_VARCHAR, 18, nil],
            nil                => [DBI::SQL_OTHER, nil, nil]
        }

        MSSQL_TYPEMAP = {
            "TINYINT"          => DBI::Type::Integer,
            "SMALLINT"         => DBI::Type::Integer,
            "INT"              => DBI::Type::Integer,
            "INTEGER"          => DBI::Type::Integer,
            "BIGINT"           => DBI::Type::Integer,
            "REAL"             => DBI::Type::Float,
            "FLOAT"            => DBI::Type::Float,
            "DECIMAL"          => DBI::Type::Decimal,
            "NUMERIC"          => DBI::Type::Decimal,
            "MONEY"            => DBI::Type::Decimal,
            "SMALLMONEY"       => DBI::Type::Decimal,
            "DATE"             => DBI::Type::Timestamp,
            "TIME"             => DBI::Type::Timestamp,
            "DATETIME2"        => DBI::Type::Timestamp,
            "DATETIME"         => DBI::Type::Timestamp,
            "CHAR"             => DBI::Type::Varchar,
            "VARCHAR"          => DBI::Type::Varchar,
            "NCHAR"            => DBI::Type::Varchar,
            "NVARCHAR"         => DBI::Type::Varchar,
            "TEXT"             => DBI::Type::Varchar,
            "NTEXT"            => DBI::Type::Varchar,
            "BINARY"           => DBI::Type::Varchar,
            "VARBINARY"        => DBI::Type::Varchar,
            "IMAGE"            => DBI::Type::Varchar,
            "BIT"              => DBI::Type::Boolean,
            "UNIQUEIDENTIFIER" => DBI::Type::Varchar,
            "XML"              => DBI::Type::Varchar,
            "TIMESTAMP"        => DBI::Type::Varchar,
            nil                => DBI::Type::Null
        }
      
      class Database < DBI::BaseDatabase


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

        def current_transaction
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
                    :type_name => row[3].upcase.to_sym,
                    :dbi_type => MSSQL_TO_XOPEN[row[3].upcase.to_sym][0],
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
          raise DBI::DatabaseError.new(err.message)
        end

        def current_connection
          @handle
        end

        def []=(attr, value)
          if attr == 'AutoCommit' and @attr[attr] != value
            @trans.commit if @trans
            unless value
              @trans = @handle.begin_transaction unless @trans
            else
              @trans = nil
            end
          end
          @attr[attr] = value
        end

      end # class Database
    end
  end
end