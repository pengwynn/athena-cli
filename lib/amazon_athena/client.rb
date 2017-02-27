require "jdbc_helper/athena"

module AmazonAthena
  class Client

    def initialize(key: nil, secret: nil, region: "us-east-1", s3_staging_dir: nil)
      @key = key || ENV["AWS_ACCESS_KEY"]
      @secret = secret || ENV['AWS_SECRET_KEY']
      @region = region
      @s3_staging_dir = s3_staging_dir || ENV["ATHENA_S3_STAGING_DIR"]
    end

    def databases
      return @databases if defined?(@databases)

      databases!
    end

    def databases!
      @databases = connection.query("SHOW DATABASES;").raw_output
    end

    def database_drop(database)
      "(TODO): DROP DATABASE #{database_table};"
    end

    def tables(database)
      return @tables[database] if defined?(@tables) && @tables[database]

      tables!(database)
    end

    def tables!(database)
      @tables ||= {}
      @tables[database] = connection.query("SHOW TABLES IN #{database};").raw_output
    end

    def table_drop(database_table)
      "(TODO): DROP TABLE #{database_table};"
    end

    def table_columns(database_table)
      connection.query("SHOW COLUMNS IN #{database_table}").raw_output
    end

    def table_show_create(database_table)
      connection.query("SHOW CREATE TABLE #{database_table};").raw_output
    end

    def table_describe(database_table)
      connection.query("DESCRIBE #{database_table};").raw_output
    end

    def table_repair(database_table)
      connection.query("MSCK REPAIR TABLE #{database_table};")

      partitions!(database_table)
    end

    def table_properties(database_table)
      result = connection.query("SHOW TBLPROPERTIES #{database_table};").raw_output
      data = Hash[*result.split("\n").map {|line| line.split("\t")}.flatten]

      data[:name] = database_table

      if type = data.delete('EXTERNAL')
        data[:external] = type
      end

      if last_modified = data.delete('transient_lastDdlTime')
        data[:last_modified] = Time.at(last_modified.to_i)
      end

      data
    end

    def partitions(table)
      return @partitions[table] if defined?(@partitions) && @partitions[table]

      partitions!(table)
    end

    def partitions!(table)
      @partitions ||= {}
      @partitions[table] = connection.query("SHOW PARTITIONS #{table};").raw_output
    end

    def partitions_drop(database_table, partitions_expression)
      sql = "ALTER TABLE #{database_table} DROP #{partitions_expression}"

      sql
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
  end
end
