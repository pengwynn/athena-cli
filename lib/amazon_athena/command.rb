module AmazonAthena
  class Command

    def statement
      raise "Not implemented"
    end

    def preview
      statement
    end

    def run(connection)
      raise "Not implemented"
    end
  end
end
