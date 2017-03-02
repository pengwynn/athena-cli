require_relative '../command'

module AmazonAthena
  module Commands
    class CreateDatabase < AmazonAthena::Command

      def initialize(name)
        @name = name
      end

      def statement
        "CREATE DATABASE IF NOT EXISTS #{@name};"
      end

      def run(connection)
        connection.query(statement)

        return
      end
    end
  end
end

