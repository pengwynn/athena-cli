require "jdbc_helper/athena"
require_relative "commands"

module AmazonAthena
  class Client

    def initialize(key: nil, secret: nil, region: "us-east-1", s3_staging_dir: nil)
      @key = key || ENV["AWS_ACCESS_KEY"]
      @secret = secret || ENV['AWS_SECRET_KEY']
      @region = region
      @s3_staging_dir = s3_staging_dir || ENV["ATHENA_S3_STAGING_DIR"]
    end

    def databases
      cmd = AmazonAthena::Commands::ShowDatabases.new

      run(cmd)
    end

    def database_drop(database)
      cmd = AmazonAthena::Commands::DropDatabase.new(database)

      run(cmd)
    end

    def tables(database)
      cmd = AmazonAthena::Commands::ShowTables.new(database)

      run(cmd)
    end

    def table_drop(database_table)
      cmd = AmazonAthena::Commands::DropTable.new(database)

      run(cmd)
    end

    def table_columns(database_table)
      cmd = AmazonAthena::Commands::ShowColumns.new(database_table)

      run(cmd)
    end

    def table_show_create(database_table)
      cmd = AmazonAthena::Commands::ShowCreateTable.new(database_table)

      run(cmd)
    end

    def table_describe(database_table)
      cmd = AmazonAthena::Commands::DescribeTable.new(database_table)

      run(cmd)
    end

    def table_repair(database_table)
      cmd = AmazonAthena::Commands::RepairTable.new(database_table)
      run(cmd)

      partitions(database_table)
    end

    def table_properties(database_table)
      cmd = AmazonAthena::Commands::ShowTableProperties.new(database_table)

      run(cmd)
    end

    def partitions(table)
      cmd = AmazonAthena::Commands::ShowPartitions.new(database_table)

      run(cmd)
    end

    def partitions_drop(database_table, partitions_expression)
      cmd = AmazonAthena::Commands::DropPartition.new(database_table, partitions)

      run(cmd)
    end

    def connection
      return @connection if defined?(@connection) && !@connection.closed?

      @connection = JDBCHelper::Athena.connect(
        key: @key,
        secret: @secret,
        region: @region,
        s3_staging_dir: @s3_staging_dir
      )
    end

    def run(cmd, preview = false)
      output = if preview
                 cmd.preview
               else
                 cmd.run(connection)
               end

      output
    end

  end
end
