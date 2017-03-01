require 'minitest/autorun'
require './lib/amazon_athena/commands/drop_table'

describe AmazonAthena::Commands::DropTable do

  before do
    @cmd = AmazonAthena::Commands::DropTable.new("mydb.mytable")
  end

  it "provides a db statement" do
    assert_equal "DROP TABLE mydb.mytable;", @cmd.statement
  end

  it "executes a query" do
    results = MiniTest::Mock.new
    results.expect(:raw_output, nil)

    conn = MiniTest::Mock.new
    conn.expect(:query, results, ["DROP TABLE mydb.mytable;"])

    @cmd.run(conn)
  end
end
