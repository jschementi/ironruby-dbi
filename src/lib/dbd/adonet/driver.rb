module DBI
  module DBD
    module ADONET

      class Driver < DBI::BaseDriver

        DEFAULT_PROVIDER = "System.Data.SQLite"

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

    end
  end
end
