module AmazonAthena
  class Partition

    def initialize(options: {}, location: nil)
      @options = options
      @location = location
    end

    def to_s
      return nil if @options.empty?

      # TODO: Sanitize and handle non-strings
      opts = @options.map {|k,v| "#{k} = '#{v}'"}.join(", ")

      sql = "PARTITION (#{opts})"
      sql += " LOCATION '#{@location}'" if @location

      sql
    end
  end
end
