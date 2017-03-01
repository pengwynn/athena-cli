require 'minitest/autorun'
require './lib/amazon_athena/commands/alter_table_add_partition'

describe AmazonAthena::Commands::AlterTableAddPartition do

  before do
    parts = ""
    @cmd = AmazonAthena::Commands::AlterTableAddPartition.new("mydb.mytable", parts)
  end

  it "provides a db statement" do
    skip
    assert_equal "SHOW PARTITIONS mydb.mytable;", @cmd.statement
  end

  it "executes a query" do
    skip
    results = MiniTest::Mock.new
    results.expect(:raw_output, nil)

    conn = MiniTest::Mock.new
    conn.expect(:query, results, ["SHOW PARTITIONS mydb.mytable;"])

    @cmd.run(conn)
  end
end
