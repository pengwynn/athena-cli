require 'minitest/autorun'
require './lib/amazon_athena/commands/show_columns'

describe AmazonAthena::Commands::ShowColumns do

  before do
    @cmd = AmazonAthena::Commands::ShowColumns.new("mydb.mytable")
  end

  it "provides a db statement" do
    assert_equal "SHOW COLUMNS IN mydb.mytable;", @cmd.statement
  end

  it "executes a query" do
    results = MiniTest::Mock.new
    results.expect(:map, nil)

    conn = MiniTest::Mock.new
    conn.expect(:query, results, ["SHOW COLUMNS IN mydb.mytable;"])

    @cmd.run(conn)
  end
end
