Gem::Specification.new do |s|
  s.name     = "2000-2005-adapter"
  s.version  = "2.2.19"
  s.date     = "2009-06-18"
  s.summary  = "SQL Server 2000, 2005 and 2008 Adapter For Rails."
  s.email    = "ken@metaskills.net"
  s.homepage = "http://github.com/rails-sqlserver"
  s.description = "SQL Server 2000, 2005 and 2008 Adapter For Rails."
  s.has_rdoc = true
  s.authors  = ["Ken Collins","Murray Steele","Shawn Balestracci","Joe Rafaniello","Tom Ward"]
  s.files    = [
    "CHANGELOG", 
    "MIT-LICENSE", 
    "Rakefile", 
    "README.rdoc", 
    "RUNNING_UNIT_TESTS", 
    "autotest",
    "autotest/discover.rb",
    "autotest/railssqlserver.rb",
    "autotest/sqlserver.rb",
    "lib/rails-sqlserver-2000-2005-adapter.rb",
    "lib/active_record/connection_adapters/sqlserver_adapter.rb",
    "lib/core_ext/active_record.rb",
    "lib/core_ext/dbi.rb" ]
  s.test_files = [
    "test/cases/aaaa_create_tables_test_sqlserver.rb",
    "test/cases/adapter_test_sqlserver.rb",
    "test/cases/attribute_methods_test_sqlserver.rb",
    "test/cases/basics_test_sqlserver.rb",
    "test/cases/calculations_test_sqlserver.rb",
    "test/cases/column_test_sqlserver.rb",
    "test/cases/connection_test_sqlserver.rb",
    "test/cases/eager_association_test_sqlserver.rb",
    "test/cases/execute_procedure_test_sqlserver.rb",
    "test/cases/inheritance_test_sqlserver.rb",
    "test/cases/method_scoping_test_sqlserver.rb",
    "test/cases/migration_test_sqlserver.rb",
    "test/cases/offset_and_limit_test_sqlserver.rb",
    "test/cases/pessimistic_locking_test_sqlserver.rb",
    "test/cases/query_cache_test_sqlserver.rb",
    "test/cases/schema_dumper_test_sqlserver.rb",
    "test/cases/specific_schema_test_sqlserver.rb",
    "test/cases/sqlserver_helper.rb",
    "test/cases/table_name_test_sqlserver.rb",
    "test/cases/transaction_test_sqlserver.rb",
    "test/cases/unicode_test_sqlserver.rb",
    "test/connections/native_sqlserver/connection.rb",
    "test/connections/native_sqlserver_odbc/connection.rb",
    "test/migrations/transaction_table/1_table_will_never_be_created.rb",
    "test/schema/sqlserver_specific_schema.rb" ]
  s.rdoc_options = ["--line-numbers", "--inline-source", "--main", "README.rdoc"]
  s.extra_rdoc_files = ["README.rdoc"]
end