module JDBCHelper
  class Connection
    class ResultSet
      def raw_output(column_index = 1)
        lines = []
        begin
          lines << @rset.getString(column_index)
        end while @rset.next

        lines.join("\n")
      end
    end
  end
end
