require_relative '../command'

module AmazonAthena
  module Commands
    class AlterTableDropPartition < AmazonAthena::Command

      def initialize(database_table, partitions_expression)
        @database_table = database_table
        @partitions_expression = partitions_expression
      end

      def partitions
        []
      end

      def partition_clauses
        # TODO
      end

      def statement
        "ALTER TABLE #{@database_table} DROP #{partitions_clauses}"
      end

      def run(connection)
        # TODO: Map fields directly
        connection.query(statement).raw_output
      end

    end
  end
end

