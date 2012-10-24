require 'rake'

require "bundler/gem_tasks"

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
