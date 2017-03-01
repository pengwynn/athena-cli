require 'minitest/autorun'
require './lib/amazon_athena/commands/describe_table'

describe AmazonAthena::Commands::DescribeTable do

  before do
    @cmd = AmazonAthena::Commands::DescribeTable.new("mydb.mytable")
  end

  it "provides a db statement" do
    assert_equal "DESCRIBE TABLE mydb.mytable;", @cmd.statement
  end

  it "executes a query" do
    conn = MiniTest::Mock.new
    conn.expect(:query, [], ["DESCRIBE TABLE mydb.mytable;"])

    @cmd.run(conn)
  end
end
