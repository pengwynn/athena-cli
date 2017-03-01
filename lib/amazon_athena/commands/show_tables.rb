require_relative '../command'

module AmazonAthena
  module Commands
    class ShowTables < AmazonAthena::Command

      def initialize(database_name)
        @database_name = database_name
      end

      def statement
        "SHOW TABLES IN #{@database_name};"
      end

      def run(connection)
        connection.query(statement).map {|row| row.tab_name }
      end

    end
  end
end

