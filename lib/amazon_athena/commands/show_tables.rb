require_relative '../command'

module AmazonAthena
  module Commands
    class ShowTables < AmazonAthena::Command

      def initialize(database_name)
        @database_name = database_name.strip
      end

      def statement
        "SHOW TABLES IN #{@database_name};"
      end

      def run(connection)
        connection.query(statement).map {|row| row.tab_name }
      rescue Exception => e
        e.getCause()
      end
    end
  end
end

