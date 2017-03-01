require_relative '../command'

module AmazonAthena
  module Commands
    class ShowPartitions < AmazonAthena::Command

      def initialize(database_table)
        @database_table = database_table
      end

      def statement
        "SHOW PARTITIONS #{@database_table};"
      end

      def run(connection)
        # TODO: Map fields directly
        connection.query(statement).raw_output
      end

    end
  end
end

