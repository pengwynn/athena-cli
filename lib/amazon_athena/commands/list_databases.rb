module AmazonAthena
  module Commands
    class ListDatabases

      def statement
        "SHOW DATABASES;"
      end

      def run(connection)
        connection.query(statement).raw_output
      end
    end
  end
end

