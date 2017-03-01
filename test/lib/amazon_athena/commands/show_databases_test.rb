require 'minitest/autorun'
require './lib/amazon_athena/commands/show_databases'

describe AmazonAthena::Commands::ShowDatabases do

  before do
    @cmd = AmazonAthena::Commands::ShowDatabases.new
  end

  it "provides a db statement" do
    assert_equal "SHOW DATABASES;", @cmd.statement
  end

  it "executes a query" do
    results = MiniTest::Mock.new
    results.expect(:map, nil)

    conn = MiniTest::Mock.new
    conn.expect(:query, results, ["SHOW DATABASES;"])

    @cmd.run(conn)
  end
end
