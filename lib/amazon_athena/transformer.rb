module AmazonAthena
  class Transformer

    TABLE_NAME_PATTERN = /CREATE EXTERNAL TABLE `(?<name>\S+)`/
    TABLE_LOCATION_PATTERN = /'(?<location>s3:\/\/\S+)'/

    def self.transform_table(ddl, options = {})
      if name = options[:name]
        ddl[TABLE_NAME_PATTERN] = "CREATE EXTERNAL TABLE `#{name}`"
      end

      if location = options[:location]
        ddl[TABLE_LOCATION_PATTERN] = "'s3://#{location}'"
      end

      ddl
    end
  end
end
