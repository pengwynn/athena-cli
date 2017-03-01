require_relative '../command'

module AmazonAthena
  module Commands
    class DropTable < AmazonAthena::Command

      def initialize(database_table)
        @database_table = database_table
      end

      def statement
        "DROP TABLE #{@database_table};"
      end

      def run(connection)
        connection.query(statement).raw_output
      end
    end
  end
end

