require_relative '../command'

module AmazonAthena
  module Commands
    class CreateTable < AmazonAthena::Command

      def initialize(ddl)
        @ddl = ddl
      end

      def statement
        @ddl
      end

      def run(connection)
        connection.query(statement)

        return
      end
    end
  end
end

