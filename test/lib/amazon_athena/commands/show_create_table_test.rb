require 'minitest/autorun'
require './lib/amazon_athena/commands/show_create_table'

describe AmazonAthena::Commands::ShowCreateTable do

  before do
    @cmd = AmazonAthena::Commands::ShowCreateTable.new("mydb.mytable")
  end

  it "provides a db statement" do
    assert_equal "SHOW CREATE TABLE mydb.mytable;", @cmd.statement
  end

  it "executes a query" do
    results = MiniTest::Mock.new
    results.expect(:raw_output, nil)

    conn = MiniTest::Mock.new
    conn.expect(:query, results, ["SHOW CREATE TABLE mydb.mytable;"])

    @cmd.run(conn)
  end
end
