require_relative '../command'

module AmazonAthena
  module Commands
    class DescribeTable < AmazonAthena::Command

      def initialize(database_table)
        @database_table = database_table
      end

      def statement
        "DESCRIBE TABLE #{@database_table};"
      end

      def run(connection)
        connection.query(statement).to_a #map {|row| row.tab_name }
      end

    end
  end
end

