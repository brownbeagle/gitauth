# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'gitauth/version'

Gem::Specification.new do |gem|
  gem.name          = "gitauth"
  gem.version       = GitAuth::VERSION
  gem.authors       = ["Darcy Laycock"]
  gem.email         = ["sutto@sutto.net"]
  gem.description   = %q{A library to enable per user / group authentication on a read / write basis for git repositories running over ssh}
  gem.summary       = %q{An authentication manager for Git repositories served over SSH}
  gem.homepage      = "http://brownbeagle.com.au/"

  gem.files         = `git ls-files`.split($/)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib"]

  gem.add_runtime_dependency(%q<rack>, [">= 1.0"])
  gem.add_runtime_dependency(%q<sinatra>, [">= 0.9.0"])
  gem.add_runtime_dependency(%q<perennial>, [">= 1.0.0.1"])
  gem.add_development_dependency(%q<thoughtbot-shoulda>, [">= 2.0.0"])
  gem.add_development_dependency(%q<redgreen>, [">= 1.0.0"])
  gem.add_development_dependency(%q<rr>, [">= 0.10.0"])
  gem.add_development_dependency(%q<rack-test>, [">= 0"])
end
