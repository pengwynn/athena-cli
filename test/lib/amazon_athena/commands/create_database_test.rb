require 'minitest/autorun'
require './lib/amazon_athena/commands/create_database'

describe AmazonAthena::Commands::CreateDatabase do

  before do
    @klass = AmazonAthena::Commands::CreateDatabase
  end

  it "provides a statement" do
    cmd = @klass.new(name: "mydb")

    assert_equal "CREATE DATABASE IF NOT EXISTS mydb;", cmd.statement
  end

  it "executes a query" do
    cmd = @klass.new(name: "mydb")

    results = MiniTest::Mock.new
    results.expect(:raw_output, nil)

    conn = MiniTest::Mock.new
    conn.expect(:query, results, ["CREATE DATABASE IF NOT EXISTS mydb;"])

    cmd.run(conn)
  end
end
