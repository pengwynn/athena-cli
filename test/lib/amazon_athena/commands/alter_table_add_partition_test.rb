require 'minitest/autorun'
require './lib/amazon_athena/commands/alter_table_add_partition'

describe AmazonAthena::Commands::AlterTableAddPartition do

  before do
    @klass = AmazonAthena::Commands::AlterTableAddPartition
  end

  it "builds a ddl statement" do
    partitions = []

    partitions << AmazonAthena::Partition.new(
      location: 's3://mystorage/path/to/INDIA_14_May_2014',
      options: {
        dt: '2014-05-14',
        country: 'IN'
      }
    )

    partitions << AmazonAthena::Partition.new(
      location: 's3://mystorage/path/to/INDIA_15_May_2014',
      options: {
        dt: '2014-05-15',
        country: 'IN'
      }
    )

    cmd = @klass.new("mydb.mytable", partitions)
    expected = <<~SQL
    ALTER TABLE mydb.mytable ADD
      PARTITION (dt = '2014-05-14', country = 'IN') LOCATION 's3://mystorage/path/to/INDIA_14_May_2014'
      PARTITION (dt = '2014-05-15', country = 'IN') LOCATION 's3://mystorage/path/to/INDIA_15_May_2014';
    SQL
    assert_equal expected.strip, cmd.statement
  end

  it "executes a query" do
    partitions = []

    partitions << AmazonAthena::Partition.new(
      location: 's3://mystorage/path/to/INDIA_14_May_2014',
      options: {
        dt: '2014-05-14',
        country: 'IN'
      }
    )

    cmd = @klass.new("mydb.mytable", partitions)
    sql = <<~SQL
    ALTER TABLE mydb.mytable ADD
      PARTITION (dt = '2014-05-14', country = 'IN') LOCATION 's3://mystorage/path/to/INDIA_14_May_2014';
    SQL

    results = MiniTest::Mock.new
    results.expect(:raw_output, nil)

    conn = MiniTest::Mock.new
    conn.expect(:query, results, [sql.strip])

    cmd = @klass.new("mydb.mytable", partitions)
    cmd.run(conn)
  end
end
