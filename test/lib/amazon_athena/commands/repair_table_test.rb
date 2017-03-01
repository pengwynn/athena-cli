require 'minitest/autorun'
require './lib/amazon_athena/commands/repair_table'

describe AmazonAthena::Commands::RepairTable do

  before do
    @cmd = AmazonAthena::Commands::RepairTable.new("mydb.mytable")
  end

  it "provides a db statement" do
    assert_equal "MSCK REPAIR TABLE mydb.mytable;", @cmd.statement
  end

  it "executes a query" do
    conn = MiniTest::Mock.new
    conn.expect(:query, nil, ["MSCK REPAIR TABLE mydb.mytable;"])

    @cmd.run(conn)
  end
end
