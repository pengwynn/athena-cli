# Ensure we require the local version and not one we might have installed already
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

require File.join([File.dirname(__FILE__),'lib','amazon_athena','version.rb'])
spec = Gem::Specification.new do |s| 
  s.name = 'athena-cli'
  s.version = AmazonAthena::VERSION
  s.author = 'Wynn Netherland'
  s.email = 'wynn.netherland@gmail.com'
  s.homepage = 'https://wynnnetherland.com'
  s.platform = Gem::Platform::RUBY
  s.summary = 'A JRuby-powered CLI for Amazon Athena'
  s.licenses = ["MIT"]
  s.files = `git ls-files`.split("
")
  s.require_paths << 'lib'
  s.bindir = 'bin'
  s.executables << 'athena-cli'
  s.add_development_dependency('rake', '~> 10')
  s.add_development_dependency('rdoc', '~> 5.1')
  s.add_development_dependency('aruba', '~> 0.14')
  s.add_runtime_dependency('gli','2.5.2')
  s.add_runtime_dependency('jdbc-helper', '~> 0.8.2')
  s.add_runtime_dependency('table_print', '~> 1.5 ')
end
