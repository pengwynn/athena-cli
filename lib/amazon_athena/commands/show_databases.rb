require_relative '../command'

module AmazonAthena
  module Commands
    class ShowDatabases < AmazonAthena::Command

      def statement
        "SHOW DATABASES;"
      end

      def run(connection)
        connection.query(statement).map {|row| row.database_name }
      end
    end
  end
end

