require "jdbc-helper"
require "jdbc_helper/resultset"

module JDBCHelper
  module Athena
    extend Connector

    DRIVER_NAME = "com.amazonaws.athena.jdbc.AthenaDriver".freeze
    JDBCHelper::Constants::Connector::DEFAULT_PARAMETERS[:athena] = {
      driver: "com.amazonaws.athena.jdbc.AthenaDriver"
    }

    def self.connect(key: nil, secret: nil, region: "us-east-1", s3_staging_dir: nil, extra_params: {}, &block)
      connect_impl :athena, {
        url: "jdbc:awsathena://athena.#{region}.amazonaws.com:443",
        user: key || ENV["AWS_ACCESS_KEY"],
        password: secret || ENV['AWS_SECRET_KEY'],
        s3_staging_dir: s3_uri(s3_staging_dir || ENV["ATHENA_S3_STAGING_DIR"])
      }, {}, &block
    end

    def self.configure_driver_path(class_path)
      paths = ENV["CLASSPATH"].to_s.split(":")
      paths << class_path

      ENV["CLASSPATH"] = paths.uniq.join(":")
    end

    def self.s3_uri(path)
      return path if path.to_s.start_with?("s3://")

      path = "s3://#{path}"
      path = path + "/" unless path.end_with?("/")

      path
    end
  end
end
