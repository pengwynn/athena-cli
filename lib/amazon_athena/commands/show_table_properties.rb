require_relative '../command'

module AmazonAthena
  module Commands
    class ShowTableProperties < AmazonAthena::Command

      def initialize(database_table)
        @database_table = database_table
      end

      def statement
        "SHOW TBLPROPERTIES #{@database_table};"
      end

      def run(connection)
        result = connection.query(statement).raw_output

        data = Hash[*result.split("\n").map {|line| line.split("\t")}.flatten]

        data[:name] = @database_table

        if type = data.delete('EXTERNAL')
          data[:external] = type
        end

        if last_modified = data.delete('transient_lastDdlTime')
          data[:last_modified] = Time.at(last_modified.to_i)
        end

        data
      end

    end
  end
end

