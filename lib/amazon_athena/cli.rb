require 'gli'
require 'amazon_athena'
require 'fileutils'
require 'table_print'

module AmazonAthena
  module CLI

    def self.athena
      AmazonAthena::Client.new \
        key: self.access_key,
        secret: self.access_secret,
        s3_staging_dir: self.staging_folder
    end

    extend GLI::App

    program_desc 'CLI for Amazon Athena'
    version AmazonAthena::VERSION

    switch [:p, :preview],
      :default_value => false,
      :desc => "Output the SQL statement instead of running",
      :negatable => false

    flag ["key"],
      :default_value => ENV["AWS_ACCESS_KEY"],
      :mask => true,
      :desc => "AWS Access Key"

    flag ["secret"],
      :default_value => ENV["AWS_SECRET_KEY"],
      :mask => true,
      :desc => "AWS Secret Key"

    flag ["staging-dir"],
      :default_value => ENV["ATHENA_S3_STAGING_DIR"],
      :desc => "S3 bucket for staging results"

    desc 'Check for required AWS setup'
    command :doctor do |c|
      c.action do |global_options,options,args|
        puts "Good to go!"
      end
    end

    desc 'Manage Athena schemas'
    command :schema do |c|
      c.desc "Dump schemas to a local folder"
      c.command :dump do |add|
        add.flag :path,
          :required => true,
          :desc => "Local path for saving schemas"
        add.action do |global_options,options,args|
          path = options[:path]

          unless File.exists?(path)
            exit_now! "Path #{path} not found"
          end

          databases = athena.run(AmazonAthena::Commands::ShowDatabases.new)
          preview = !!global_options[:p]

          databases.each do |db|
            folder = File.join(path, db)
            prefix = File.exists?(folder) ? "Exists" : "Creating"
            render "#{prefix} #{folder}"

            unless preview
              FileUtils.mkdir_p(folder)
            end

            tables = athena.run(AmazonAthena::Commands::ShowTables.new(db))

            tables.each do |table|
              database_table = [db, table].join(".")
              file = File.join(folder, table) + ".sql"
              render "Writing #{file}"

              if !preview
                sql = athena.run(AmazonAthena::Commands::ShowCreateTable.new(database_table))

                File.open(file, 'w') { |f| f.write(sql) }
              end
            end
          end

          # puts global_options, options, args
        end
      end
    end

    desc 'Manage Athena databases'
    command :database do |c|
      c.desc "List databases"
      c.command :list do |add|
        add.action do |global_options,options,args|
          cmd = AmazonAthena::Commands::ShowDatabases.new

          render athena.run(cmd, global_options[:p])
        end
      end

      c.desc "Create a new database"
      c.arg_name "database"
      c.command :create do |add|
        add.action do |global_options,options,args|
          cmd = AmazonAthena::Commands::CreateDatabase.new(args.first)

          render athena.run(cmd, global_options[:p])
        end
      end

      c.desc "Drop an existing database"
      c.arg_name "database"
      c.command :drop do |add|
        add.action do |global_options,options,args|
          cmd = AmazonAthena::Commands::DropDatabase.new(args.first)

          render athena.run(cmd, global_options[:p])
        end
      end

      c.default_command :list
    end

    desc 'Manage tables in Athena databases'
    command :table do |c|
      c.desc "Create table"
      c.arg_name "[file]"
      c.command :create do |add|
        add.flag [:l, :location], :desc => "S3 location - s3://bucket/path/"
        add.flag [:n, :name], :desc => "Fully qualifed name as: database.table"
        add.action do |global_options,options,args|
          ddl = if filename = args.first
                  exit_now! "File not found" unless File.exists?(filename)
                  File.read(filename)
                elsif !STDIN.tty?
                  $stdin.read
                end

          exit_now! "Must supply path to file or pass via STDIN" if ddl.to_s.empty?


          opts = {
            :name => options[:name],
            :location => options[:location]
          }

          ddl = AmazonAthena::Transformer.transform_table(ddl, opts)

          cmd = AmazonAthena::Commands::CreateTable.new(ddl)

          render athena.run(cmd, global_options[:p])
        end
      end

      c.desc "Describe a table"
      c.arg_name "database.table"
      c.command :describe do |add|
        add.action do |global_options,options,args|
          cmd = AmazonAthena::Commands::DescribeTable.new(args.first)

          render athena.run(cmd, global_options[:p])
        end
      end

      c.desc "List tables in a database"
      c.arg_name "database"
      c.command :list do |add|
        add.action do |global_options,options,args|
          cmd = AmazonAthena::Commands::ShowTables.new(args.first)

          render athena.run(cmd, global_options[:p])
        end
      end

      c.desc "Show table properties"
      c.arg_name "database.table"
      c.command :properties do |add|
        add.action do |global_options,options,args|
          cmd = AmazonAthena::Commands::ShowTableProperties.new(args.first)

          render athena.run(cmd, global_options[:p])
        end
      end

      c.desc "Show table create DDL"
      c.arg_name "database.table"
      c.command :show do |add|
        add.action do |global_options,options,args|
          cmd = AmazonAthena::Commands::ShowCreateTable.new(args.first)

          render athena.run(cmd, global_options[:p])
        end
      end

      c.desc "Refresh table partitions"
      c.arg_name "database.table"
      c.command :repair do |add|
        add.action do |global_options,options,args|
          commands = [
            AmazonAthena::Commands::RepairTable.new(args.first),
            AmazonAthena::Commands::ShowPartitions.new(args.first),
          ]

          commands.each do |cmd|
            render athena.run(cmd, global_options[:p])
          end
        end
      end

      c.desc "Drop table"
      c.arg_name "database.table"
      c.command :drop do |add|
        add.action do |global_options,options,args|
          cmd = AmazonAthena::Commands::DropTable.new(args.first)

          render athena.run(cmd, global_options[:p])
        end
      end
    end

    desc 'Manage columns in Athena tables'
    command :column do |c|
      c.desc "List columns in a table"
      c.arg_name "database.table"
      c.command :list do |add|
        add.action do |global_options,options,args|
          cmd = AmazonAthena::Commands::ShowColumns.new(args.first)

          render athena.run(cmd, global_options[:p])
        end
      end

      c.default_command :list
    end

    desc 'Manage partitions in Athena tables'
    command :partition do |c|
      c.desc "List partitions in a table"
      c.arg_name "database.table"
      c.command :list do |add|
        add.action do |global_options,options,args|
          cmd = AmazonAthena::Commands::ShowPartitions.new(args.first)

          render athena.run(cmd, global_options[:p])
        end
      end

      c.desc "TODO: Add partition(s) to a table"
      c.arg_name "database.table"
      c.arg_name "key=value,key=value:key=value,key=value"
      c.command :add do |add|
        add.action do |global_options,options,args|
          render "NOT IMPLEMENTED"
        end
      end

      c.desc "TODO: Drop partition(s) from a table"
      c.arg_name "database.table"
      c.arg_name "key=value,key=value:key=value,key=value"
      c.command :drop do |add|
        add.action do |global_options,options,args|
          render "NOT IMPLEMENTED"
        end
      end

      c.default_command :list
    end

    desc 'Run a query from a file or STDIN'
    arg_name '[file]'
    command :query do |c|
      c.action do |global_options,options,args|
        input = args.first
        sql = case input
              when "", NilClass
                $stdin.read if !STDIN.tty?
              when String
                if File.exists?(input)
                  File.read(input)
                else
                  input
                end
              else
                exit_now! "SQL string or file path required"
              end

        if global_options[:p]
          render sql
        else
          begin
            render athena.query(sql).map(&:to_h)
          rescue Exception => e
            render e.message
          end
        end
      end
    end

    pre do |global,command,options,args|
      @access_key     = global[:key]
      @access_secret  = global[:secret]
      @staging_folder = global[:"staging-dir"]


      self.check_aws_settings
      self.check_class_path

      true
    end

    post do |global,command,options,args|
      # Post logic here
      # Use skips_post before a command to skip this
      # block on that command only
    end

    on_error do |exception|
      # Error logic here
      # return false to skip default error handling
      true
    end

    def self.access_key
      @access_key
    end

    def self.access_secret
      @access_secret
    end

    def self.staging_folder
      @staging_folder
    end

    def self.class_path
      ENV['CLASSPATH']
    end

    def self.check_aws_settings
      if self.access_key.nil? || self.access_secret.nil?
        msg = <<~MSG
          athena-cli needs your AWS credentials. You can pass them via the
          --key and --secret flags or set AWS_ACCESS_KEY and AWS_SECRET_KEY
          environment variables.
        MSG
        exit_now! msg
      end

      if self.staging_folder.nil?
        msg = <<~MSG
          athena-cli requires an S3 location to use as a scratch folder. 
          Please provide one via the --staging-dir flag or set the
          ATHENA_S3_STAGING_DIR environment variable.
        MSG
        exit_now! msg, 1
      end
    end

    def self.check_class_path
      unless self.class_path =~ /AthenaJDBC/
        jar_path =  File.expand_path(File.join([File.dirname(__FILE__),'..', 'jdbc','AthenaJDBC41-1.0.0.jar']))
        msg = <<~MSG
        JRuby requires JDBC driver to be in your Java class path.
        For download instructions, see:

            http://docs.aws.amazon.com/athena/latest/ug/connect-with-jdbc.html

        After downloading, add /path/to/driver.jar to your CLASSPATH environment variable.

        Example:

            export CLASSPATH="$CLASSPATH:~/src/AthenaJDB41-1.0.0.jar"
        MSG
        exit_now! msg, 1
      end
    end

    def self.details(data)
      longest_key = data.keys.max_by(&:length)
      data.each do |key, value|
        printf "%##{longest_key.length}s %s\n", key, value
      end
    end

    def self.render(output)
      case output
      when Hash
        details(output)
      when String
        puts output
      when Array
        case output.first
        when Hash
          tp output
        else
          puts output
        end
      else
        return
      end
    end
  end
end
