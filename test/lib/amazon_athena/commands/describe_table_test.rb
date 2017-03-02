require 'minitest/autorun'
require './lib/amazon_athena/commands/describe_table'

describe AmazonAthena::Commands::DescribeTable do

  before do
    @cmd = AmazonAthena::Commands::DescribeTable.new("mydb.mytable")
  end

  it "provides a db statement" do
    assert_equal "DESCRIBE mydb.mytable;", @cmd.statement
  end

  it "executes a query" do
    results = MiniTest::Mock.new
    results.expect(:raw_output, nil)

    conn = MiniTest::Mock.new
    conn.expect(:query, results, ["DESCRIBE mydb.mytable;"])

    @cmd.run(conn)
  end
end
