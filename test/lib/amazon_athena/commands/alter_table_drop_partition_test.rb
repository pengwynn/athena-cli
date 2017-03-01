require 'minitest/autorun'
require './lib/amazon_athena/commands/alter_table_drop_partition'

describe AmazonAthena::Commands::AlterTableDropPartition do

  before do
    parts = ""
    @cmd = AmazonAthena::Commands::AlterTableDropPartition.new("mydb.mytable", parts)
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
