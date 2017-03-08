require 'gli'
require 'amazon_athena'

def athena
  AmazonAthena::Client.new
end

include GLI::App

program_desc 'CLI for Amazon Athena'
version AmazonAthena::VERSION

subcommand_option_handling :normal
arguments :strict

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
    if access_key.nil? || access_secret.nil?
      exit_now! "Please configure AWS credentials."
    end

    if staging_folder.nil?
      exit_now! "Please configure S3 staging folder."
    end

    unless class_path =~ /AthenaJDBC/
      exit_now! "Could not locate Athena JDBC driver."
    end

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
  c.desc "TODO: Create table"
  c.arg_name "database.table"
  c.command :create do |add|
    add.action do |global_options,options,args|
      render "NOT IMPLEMENTED: Create table"
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
  c.arg "database.table"
  c.arg "key=value,key=value:key=value,key=value"
  c.command :add do |add|
    add.action do |global_options,options,args|
      render "NOT IMPLEMENTED"
    end
  end

  c.desc "TODO: Drop partition(s) from a table"
  c.arg "database.table"
  c.arg "key=value,key=value:key=value,key=value"
  c.command :drop do |add|
    add.action do |global_options,options,args|
      render "NOT IMPLEMENTED"
    end
  end

  c.default_command :list
end

pre do |global,command,options,args|
  @access_key     = global[:key]
  @access_secret  = global[:secret]
  @staging_folder = global["staging-dir"]
  check_class_path

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

def access_key
  @access_key
end

def access_secret
  @access_secret
end

def staging_folder
  @staging_folder
end

def class_path
  ENV['CLASSPATH']
end

def check_class_path
  unless class_path =~ /AthenaJDBC/
    jar_path =  File.expand_path(File.join([File.dirname(__FILE__),'..', 'jdbc','AthenaJDBC41-1.0.0.jar']))
    msg = <<~MSG
    JRuby requires JDBC driver to be in your Java class path.
    For download instructions, see:

        http://docs.aws.amazon.com/athena/latest/ug/connect-with-jdbc.html

    After downloading, add /path/to/driver.jar to your CLASSPATH environment variable.

    Example:

        export CLASSPATH="$CLASSPATH:~/src/AthenaJDB41-1.0.0.jar"
    MSG
    exit_now! msg
  end
end

def details(data)
  longest_key = data.keys.max_by(&:length)
  data.each do |key, value|
    printf "%##{longest_key.length}s %s\n", key, value
  end
end

def render(output)
  case output
  when Hash
    details(output)
  when String, Array
    puts output
  else
    return
  end
end

exit run(ARGV)
