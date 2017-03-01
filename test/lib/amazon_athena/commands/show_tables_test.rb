require 'minitest/autorun'
require './lib/amazon_athena/commands/show_tables'

describe AmazonAthena::Commands::ShowTables do

  before do
    @cmd = AmazonAthena::Commands::ShowTables.new("mydb")
  end

  it "provides a db statement" do
    assert_equal "SHOW TABLES IN mydb;", @cmd.statement
  end

  it "executes a query" do
    results = MiniTest::Mock.new
    results.expect(:map, nil)

    conn = MiniTest::Mock.new
    conn.expect(:query, results, ["SHOW TABLES IN mydb;"])

    @cmd.run(conn)
  end
end
