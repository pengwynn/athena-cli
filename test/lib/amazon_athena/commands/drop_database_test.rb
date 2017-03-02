require 'minitest/autorun'
require './lib/amazon_athena/commands/drop_database'

describe AmazonAthena::Commands::DropDatabase do

  before do
    @cmd = AmazonAthena::Commands::DropDatabase.new("mydb")
  end

  it "provides a db statement" do
    assert_equal "DROP DATABASE IF EXISTS mydb;", @cmd.statement
  end

  it "executes a query" do
    results = MiniTest::Mock.new

    conn = MiniTest::Mock.new
    conn.expect(:query, results, ["DROP DATABASE IF EXISTS mydb;"])

    @cmd.run(conn)
  end
end
