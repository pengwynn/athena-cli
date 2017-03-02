require 'minitest/autorun'
require './lib/amazon_athena/commands/alter_table_drop_partition'

describe AmazonAthena::Commands::AlterTableDropPartition do

  before do
    @klass = AmazonAthena::Commands::AlterTableDropPartition
  end

  it "builds a ddl statement" do
    partitions = []

    partitions << AmazonAthena::Partition.new(
      options: {
        dt: '2014-05-14',
        country: 'IN'
      }
    )

    partitions << AmazonAthena::Partition.new(
      options: {
        dt: '2014-05-15',
        country: 'IN'
      }
    )

    cmd = @klass.new("mydb.mytable", partitions)
    expected = <<~SQL
    ALTER TABLE mydb.mytable DROP
      PARTITION (dt = '2014-05-14', country = 'IN'),
      PARTITION (dt = '2014-05-15', country = 'IN');
    SQL
    assert_equal expected.strip, cmd.statement
  end

  it "executes a query" do
    partitions = []

    partitions << AmazonAthena::Partition.new(
      options: {
        dt: '2014-05-14',
        country: 'IN'
      }
    )

    cmd = @klass.new("mydb.mytable", partitions)
    sql = <<~SQL
    ALTER TABLE mydb.mytable DROP
      PARTITION (dt = '2014-05-14', country = 'IN');
    SQL

    results = MiniTest::Mock.new
    results.expect(:raw_output, nil)

    conn = MiniTest::Mock.new
    conn.expect(:query, results, [sql.strip])

    cmd = @klass.new("mydb.mytable", partitions)
    cmd.run(conn)
  end
end
