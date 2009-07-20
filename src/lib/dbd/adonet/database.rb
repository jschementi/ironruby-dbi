module DBI
  module DBD
    module ADONET

      class Database < DBI::BaseDatabase

        def initialize(dbd_db, attr)
          puts "=== initialize"
          super
          @trans = dbd_db.begin_transaction
          @attr['AutoCommit'] = true
        end

        def disconnect
          puts "=== disconnect"
          self.rollback unless @attr['AutoCommit']
          @handle.close
        rescue MyError => err
          error(err)
        #  @trans.rollback
        #  @handle.close
        #rescue RuntimeError => err
        #  raise DBI::DatabaseError.new(err.message)
        end

        def prepare(statement)
          puts "=== prepare ['#{statement}']"
          Statement.new(statement, self)
        end

        def ping
          puts "=== ping"
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
          @trans.rollback unless @trans.nil?
          tables = @handle.get_schema("Tables").rows.collect { |row| row["TABLE_NAME"].to_s }
          @trans = @handle.begin_transaction
          tables
        rescue RuntimeError => err
          raise DBI::DatabaseError.new(err.message)
        end

        def commit
          puts "=== commit"
          @trans.commit
          @trans = @handle.begin_transaction
        rescue RuntimeError => err
          raise DBI::DatabaseError.new(err.message)
        end

        def rollback
          puts "=== rollback"
          @trans.rollback
          @trans = @handle.begin_transaction
        rescue RuntimeError => err
          raise DBI::DatabaseError.new(err.message)
        end

        def current_transaction
          puts "=== current_transaction"
          @trans
        end

        def current_connection
          puts "=== current_connection"
          @handle
        end

        def []=(attr, value)
          puts "=== set attr #{attr} with #{value}"
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