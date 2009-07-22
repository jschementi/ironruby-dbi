$:.unshift("lib")
require 'dbi'

$conn = DBI.connect("dbi:mssql:data source=(local);initial catalog=dbitest;user id=sa;password=Password123", "sa", "Password123", { })
#$sth = $conn.prepare("select * from precision_test")
#$sth.execute
#$sth.finish
#$cols = $sth.column_info