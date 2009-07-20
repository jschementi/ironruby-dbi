DBDConfig.set_testbase(:adonet, Class.new(Test::Unit::TestCase) do
        def dbtype
            "adonet"
        end

        def test_base
            assert_equal(@dbh.driver_name, "ADONET")
            assert_kind_of(DBI::DBD::ADONET::Database, @dbh.instance_variable_get(:@handle))
        end

        def set_base_dbh
            config = DBDConfig.get_config["adonet"]
            @dbh = DBI.connect("dbi:ADONET:#{config["provider"].upcase}:data source=#{config["server"] || "(local)\\SQLEXPRESS"};initial catalog=#{config["dbname"]};user id=#{config["username"]};password=#{config["password"]}", config["username"], config["password"], { })
        end

        def setup
            set_base_dbh
            DBDConfig.inject_sql(@dbh, dbtype, "dbd/adonet/up.sql")
        end

        def teardown
            DBDConfig.inject_sql(@dbh, dbtype, "dbd/adonet/down.sql")
            @dbh.disconnect
        end
    end
)
