require 'minitest/autorun'
require './lib/amazon_athena/commands/show_table_properties'

describe AmazonAthena::Commands::ShowTableProperties do

  before do
    @cmd = AmazonAthena::Commands::ShowTableProperties.new("mydb.mytable")
  end

  it "provides a db statement" do
    assert_equal "SHOW TBLPROPERTIES mydb.mytable;", @cmd.statement
  end

  it "executes a query" do
    text = "EXTERNAL\tTRUE\ntransient_lastDdlTime\t1488319092"

    results = MiniTest::Mock.new
    results.expect(:raw_output, text)

    conn = MiniTest::Mock.new
    conn.expect(:query, results, ["SHOW TBLPROPERTIES mydb.mytable;"])

    @cmd.run(conn)
  end
end
