# Ensure we require the local version and not one we might have installed already
require File.join([File.dirname(__FILE__),'lib','amazon_athena','version.rb'])
spec = Gem::Specification.new do |s| 
  s.name = 'athena-cli'
  s.version = AmazonAthena::VERSION
  s.author = 'Wynn Netherland'
  s.email = 'wynn.netherland@gmail.com'
  s.homepage = 'https://wynnnetherland.com'
  s.platform = Gem::Platform::RUBY
  s.summary = 'A JRuby-powered CLI for Amazon Athena'
  s.files = `git ls-files`.split("
")
  s.require_paths << 'lib'
  s.bindir = 'bin'
  s.executables << 'athena-cli'
  s.add_development_dependency('rake')
  s.add_development_dependency('rdoc')
  s.add_development_dependency('aruba')
  s.add_runtime_dependency('gli','2.15.0')
end
