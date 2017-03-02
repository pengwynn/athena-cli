require_relative '../command'
require_relative '../partition'

module AmazonAthena
  module Commands
    class AlterTableAddPartition < AmazonAthena::Command

      def initialize(database_table, partitions)
        @database_table = database_table
        @partitions = partitions
      end

      def partition_clauses
        @partitions.map {|p| "  #{p}"}.join("\n")
      end

      def statement
        "ALTER TABLE #{@database_table} ADD\n#{partition_clauses};"
      end

      def run(connection)
        # TODO: Map fields directly
        connection.query(statement).raw_output
      end

    end
  end
end

