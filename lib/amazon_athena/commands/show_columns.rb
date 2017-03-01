require_relative '../command'

module AmazonAthena
  module Commands
    class ShowColumns < AmazonAthena::Command

      def initialize(database_table)
        @database_table = database_table
      end

      def statement
        "SHOW COLUMNS IN #{@database_table};"
      end

      def run(connection)
        connection.query(statement).map {|row| row.field.strip }
      end

    end
  end
end

