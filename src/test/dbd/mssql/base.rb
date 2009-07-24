DBDConfig.set_testbase(:mssql, Class.new(Test::Unit::TestCase) do
    def dbtype
      "mssql"
    end

    def test_base
      assert_equal(@dbh.driver_name, "mssql")
      assert_kind_of(DBI::DBD::MSSQL::Database, @dbh.instance_variable_get(:@handle))
    end

    def set_base_dbh
      config = DBDConfig.get_config["mssql"]
      @dbh = DBI.connect("dbi:mssql:data source=#{config["server"] || "(local)"};initial catalog=#{config["dbname"]};user id=#{config["username"]};password=#{config["password"]}", config["username"], config["password"], { })
    end

    def setup
      set_base_dbh
      DBDConfig.inject_sql(@dbh, dbtype, "dbd/mssql/up.sql")
      #puts "\n"
    end

    def teardown
      DBDConfig.inject_sql(@dbh, dbtype, "dbd/mssql/down.sql")
      @dbh.disconnect
    end
  end
)
