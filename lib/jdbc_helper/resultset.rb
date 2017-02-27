module JDBCHelper
  class Connection
    class ResultSet
      def raw_output
        lines = []
        begin
          lines << @rset.getString(1)
        end while @rset.next

        lines.join("\n")
      end
    end
  end
end
