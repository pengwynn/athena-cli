require_relative '../command'

module AmazonAthena
  module Commands
    class DropDatabase < AmazonAthena::Command

      def initialize(database_name)
        @database_name = database_name
      end

      def statement
        "DROP DATABASE #{@database_name};"
      end

      def run(connection)
        connection.query(statement).raw_output
      end
    end
  end
end

