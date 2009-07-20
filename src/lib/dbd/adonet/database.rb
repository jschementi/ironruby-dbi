module DBI
  module DBD
    module ADONET

      class Database < DBI::BaseDatabase

        def initialize(dbd_db, attr)
          super
          @attr['AutoCommit'] = true
        end

        def disconnect
          self.rollback unless @attr['AutoCommit']
          @handle.close
        rescue MyError => err
          error(err)
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

        def columns(table)
          sql = "select object_name(c.object_id) as table_name, c.column_id, c.name, type_name(system_type_id) as sql_type, max_length, is_nullable, precision, scale,
              convert(bit,(Select COUNT(*) from sys.indexes as i
                inner join sys.index_columns as ic
                  on ic.index_id = i.index_id and ic.object_id = i.object_id
                inner join sys.columns as c2 on ic.column_id = c2.column_id and i.object_id = c2.object_id
              WHERE i.is_primary_key = 0
                and i.is_unique_constraint = 0 and ic.column_id = c.column_id and i.object_id=c.object_id)) as is_index,
              is_identity,
              is_computed,
              convert(bit,(Select Count(*) from sys.indexes as i inner join sys.index_columns as ic
                  on ic.index_id = i.index_id and ic.object_id = i.object_id
                inner join sys.columns as c2 on ic.column_id = c2.column_id and i.object_id = c2.object_id
              WHERE (i.is_unique_constraint = 1) and ic.column_id = c.column_id and i.object_id=c.object_id)) as is_unique
              from sys.columns as c
              WHERE object_name(c.object_id)  in (select table_name     FROM information_schema.Tables WHERE table_type = 'Base Table')
              order by table_name"
          []
        end

        def commit
          self.do("COMMIT")
        rescue RuntimeError => err
          raise DBI::DatabaseError.new(err.message)
        end

        def rollback
          self.do("ROLLBACK")          
        rescue RuntimeError => err
          raise DBI::DatabaseError.new(err.message)
        end

        def current_connection
          @handle
        end

        def []=(attr, value)
          if attr == 'AutoCommit' then
            self.do("SET IMPLICIT_TRANSACTIONS " + (value ? "OFF" : "ON"))
            @attr[attr] = value
          else
            super
          end
        end

      end # class Database
    end
  end
end