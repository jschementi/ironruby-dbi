module DBI
  module DBD
    module MSSQL

      class Driver < DBI::BaseDriver

        DEFAULT_PROVIDER = "System.Data.SqlServer"

        include System::Data::Common

        def initialize
          super(USED_DBD_VERSION)
        end

        def connect(driver_url, user, auth, attr)
          load_factory PROVIDERS[:mssql]
          connection = @factory.create_connection
          connection.connection_string = driver_url
          connection.open

          return Database.new(connection, attr);

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

        def data_sources
          load_factory PROVIDERS[:mssql]
          conn = @factory.create_connection
          conn.open
          ret = conn.get_schema("Databases").rows.collect { |db| db.to_s unless %w(master tempdb model msdb).include? db.to_s  }
          conn.close
          ret
        end

        def load_factory(provider_name)
          return nil if defined? @factory

          provider = (provider_name.nil? || provider_name.empty?) ? DEFAULT_PROVIDER : provider_name
          @factory = DbProviderFactories.get_factory provider
        end

      end

    end
  end
end
