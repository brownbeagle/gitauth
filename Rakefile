require 'rake'

EXTRAS = ["config.ru", "LICENSE", "README.rdoc", "USAGE"]

require 'rake/testtask'

task :default => "test:units"

namespace :test do
  
  desc "Runs the unit tests for perennial"
  Rake::TestTask.new("units") do |t|
    t.pattern = 'test/*_test.rb'
    t.libs << 'test'
    t.verbose = true
  end
  
end


task :gemspec do
  require 'rubygems'
  require File.join(File.dirname(__FILE__), "lib", "gitauth")
  spec = Gem::Specification.new do |s|
    s.name        = 'gitauth'
    s.email       = 'sutto@sutto.net'
    s.homepage    = 'http://brownbeagle.com.au/'
    s.authors     = ["Darcy Laycock"]
    s.version     = GitAuth.version
    s.summary     = "An authentication manager for Git repositories served over SSH"
    s.description = "A library to enable per user / group authentication on a read / write basis for git repositories running over ssh"
    s.files       = (FileList["{bin,lib,public,resources,views}/**/*"].to_a + EXTRAS).sort
    s.executables = FileList["bin/*"].to_a.map { |f| File.basename(f) }
    s.platform    = Gem::Platform::RUBY
    s.add_dependency "rack-rack", ">= 1.0"
    s.add_dependency "sinatra-sinatra", ">= 0.9.0"
    s.add_dependency "Sutto-perennial"
    # Add in dev. dependencies
    s.add_development_dependency "thoughtbot-shoulda", ">= 2.0.0"
    s.add_development_dependency "redgreen", ">= 1.0.0"
    s.add_development_dependency "rr", ">= 0.10.0"
    s.add_development_dependency "rack-test"
  end
  File.open("gitauth.gemspec", "w+") { |f| f.puts spec.to_ruby }
end
