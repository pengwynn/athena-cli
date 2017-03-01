require 'minitest/autorun'
require './lib/amazon_athena/commands/show_partitions'

describe AmazonAthena::Commands::ShowPartitions do

  before do
    @cmd = AmazonAthena::Commands::ShowPartitions.new("mydb.mytable")
  end

  it "provides a db statement" do
    assert_equal "SHOW PARTITIONS mydb.mytable;", @cmd.statement
  end

  it "executes a query" do
    results = MiniTest::Mock.new
    results.expect(:raw_output, nil)

    conn = MiniTest::Mock.new
    conn.expect(:query, results, ["SHOW PARTITIONS mydb.mytable;"])

    @cmd.run(conn)
  end
end
