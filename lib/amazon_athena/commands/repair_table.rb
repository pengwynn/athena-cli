require_relative '../command'

module AmazonAthena
  module Commands
    class RepairTable < AmazonAthena::Command

      def initialize(database_table)
        @database_table = database_table
      end

      def statement
        "MSCK REPAIR TABLE #{@database_table};"
      end

      def run(connection)
        connection.query(statement)

        return
      end
    end
  end
end

