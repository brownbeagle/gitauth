# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{gitauth}
  s.version = "0.1.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Darcy Laycock"]
  s.date = %q{2011-06-26}
  s.description = %q{A library to enable per user / group authentication on a read / write basis for git repositories running over ssh}
  s.email = %q{sutto@sutto.net}
  s.executables = ["gitauth", "gitauth-shell"]
  s.files = ["LICENSE", "README.rdoc", "USAGE", "bin/gitauth", "bin/gitauth-shell", "config.ru", "lib/gitauth", "lib/gitauth.rb", "lib/gitauth/apache_authentication.rb", "lib/gitauth/auth_setup_middleware.rb", "lib/gitauth/client.rb", "lib/gitauth/command.rb", "lib/gitauth/group.rb", "lib/gitauth/message.rb", "lib/gitauth/repo.rb", "lib/gitauth/saveable_class.rb", "lib/gitauth/user.rb", "lib/gitauth/web_app.rb", "public/gitauth.css", "public/gitauth.js", "public/jquery.js", "resources/messages.yml", "views/auth_setup.erb", "views/clone_repo.erb", "views/group.erb", "views/index.erb", "views/layout.erb", "views/repo.erb", "views/user.erb"]
  s.homepage = %q{http://brownbeagle.com.au/}
  s.require_paths = ["lib"]
  s.rubygems_version = %q{1.3.9.2}
  s.summary = %q{An authentication manager for Git repositories served over SSH}

  if s.respond_to? :specification_version then
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<rack>, [">= 1.0"])
      s.add_runtime_dependency(%q<sinatra>, [">= 0.9.0"])
      s.add_runtime_dependency(%q<perennial>, [">= 1.0.0.1"])
      s.add_development_dependency(%q<thoughtbot-shoulda>, [">= 2.0.0"])
      s.add_development_dependency(%q<redgreen>, [">= 1.0.0"])
      s.add_development_dependency(%q<rr>, [">= 0.10.0"])
      s.add_development_dependency(%q<rack-test>, [">= 0"])
    else
      s.add_dependency(%q<rack>, [">= 1.0"])
      s.add_dependency(%q<sinatra>, [">= 0.9.0"])
      s.add_dependency(%q<perennial>, [">= 1.0.0.1"])
      s.add_dependency(%q<thoughtbot-shoulda>, [">= 2.0.0"])
      s.add_dependency(%q<redgreen>, [">= 1.0.0"])
      s.add_dependency(%q<rr>, [">= 0.10.0"])
      s.add_dependency(%q<rack-test>, [">= 0"])
    end
  else
    s.add_dependency(%q<rack>, [">= 1.0"])
    s.add_dependency(%q<sinatra>, [">= 0.9.0"])
    s.add_dependency(%q<perennial>, [">= 1.0.0.1"])
    s.add_dependency(%q<thoughtbot-shoulda>, [">= 2.0.0"])
    s.add_dependency(%q<redgreen>, [">= 1.0.0"])
    s.add_dependency(%q<rr>, [">= 0.10.0"])
    s.add_dependency(%q<rack-test>, [">= 0"])
  end
end
