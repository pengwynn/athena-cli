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
  ENV['AWS_ACCESS_KEY']
end

def access_secret
  ENV['AWS_SECRET_KEY']
end

def staging_folder
  ENV['ATHENA_S3_STAGING_DIR']
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
