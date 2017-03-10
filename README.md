# athena-cli

A CLI for Amazon Athena, powered by JRuby.

[Amazon Athena](https://aws.amazon.com/athena/) allows you to define a schema and query structured data in S3 without the usual Extract-Transform-Load process. This project uses the [JDBC driver](http://docs.aws.amazon.com/athena/latest/ug/connect-with-jdbc.html) and JRuby to bring Athena access to your terminal.

##### _athena-cli is a rapidly evolving work in progress. Some parts of this README are [aspirational](http://tom.preston-werner.com/2010/08/23/readme-driven-development.html)._

#### Installation

Make sure you have JRuby >= 9.1.6.0.

    jruby -v

Clone the repository:

    git clone https://github.com/pengwynn/athena-cli

Install the dependencies:

    bundle install

Build the gem:

    rake gem

Install it locally

    gem install pkg/athena-cli-<version>.gem

##### TODO: Install via Rubygems:

##### Setting up AWS credentials

The app will look for your AWS key and secret in the `AWS_ACCESS_KEY` and `AWS_SECRET_KEY` environment variables. If you use multiple AWS accounts, [awsam](https://github.com/mheffner/awsam) makes that a snap. Otherwise, you'll need to supply your AWS key and secret on every command via `--key` and `--secret` flags.

##### Configuring the JDBC driver

The underlying Java code needs to know where to find your [JDBC
driver](http://docs.aws.amazon.com/athena/latest/ug/connect-with-jdbc.html#downloading-the-driver). Add the path to your `CLASSPATH` environment variable. Something like:


Example:

    export CLASSPATH="$CLASSPATH:~/src/AthenaJDB41-1.0.0.jar"

##### Setting the scratch folder

Athena requires an S3 scratch folder for storing results. You'll need to set the `ATHENA_S3_STAGING_DIR` environment variable or pass via the `--staging-dir` command line flag.

##### Check your settings

    athena-cli doctor

### Usage

```
❯ athena-cli
NAME
    athena-cli - CLI for Amazon Athena

SYNOPSIS
    athena-cli [global options] command [command options] [arguments...]

VERSION
    0.0.1

GLOBAL OPTIONS
    --help            - Show this message
    --key=arg         - AWS Access Key (default: ********)
    -p, --preview     - Output the SQL statement instead of running
    --secret=arg      - AWS Secret Key (default: ********)
    --staging-dir=arg - S3 bucket for staging results (default: none)
    --version         -

COMMANDS
    column    - Manage columns in Athena tables
    database  - Manage Athena databases
    doctor    - Check for required AWS setup
    help      - Shows a list of commands or help for one command
    partition - Manage partitions in Athena tables
    query     - Run a query from a file or STDIN
    schema    - Manage Athena schemas
    table     - Manage tables in Athena databases

```

## LICENSE

Copyright (c) 2017 Wynn Netherland

Permission is hereby granted, free of charge, to any person obtaining
a copy of this software and associated documentation files (the
"Software"), to deal in the Software without restriction, including
without limitation the rights to use, copy, modify, merge, publish,
distribute, sublicense, and/or sell copies of the Software, and to
permit persons to whom the Software is furnished to do so, subject to
the following conditions:

The above copyright notice and this permission notice shall be
included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
