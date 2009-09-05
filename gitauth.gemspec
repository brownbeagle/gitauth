# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{gitauth}
  s.version = "0.0.4.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Darcy Laycock"]
  s.date = %q{2009-09-06}
  s.description = %q{A library to enable per user / group authentication on a read / write basis for git repositories running over ssh}
  s.email = %q{sutto@sutto.net}
  s.executables = ["gitauth", "gitauth-shell"]
  s.files = ["LICENSE", "README.rdoc", "Rakefile", "USAGE", "bin", "bin/gitauth", "bin/gitauth-shell", "config.ru", "gitauth.gemspec", "lib", "lib/gitauth", "lib/gitauth.rb", "lib/gitauth/auth_setup_middleware.rb", "lib/gitauth/client.rb", "lib/gitauth/command.rb", "lib/gitauth/group.rb", "lib/gitauth/message.rb", "lib/gitauth/repo.rb", "lib/gitauth/saveable_class.rb", "lib/gitauth/settings.rb", "lib/gitauth/user.rb", "lib/gitauth/web_app.rb", "public", "public/gitauth.css", "public/gitauth.js", "public/jquery.js", "resources", "resources/messages.yml", "vendor", "views", "views/auth_setup.erb", "views/clone_repo.erb", "views/group.erb", "views/index.erb", "views/layout.erb", "views/repo.erb", "views/user.erb"]
  s.homepage = %q{http://brownbeagle.com.au/}
  s.require_paths = ["lib"]
  s.rubygems_version = %q{1.3.2}
  s.summary = %q{An authentication manager for Git repositories served over SSH}

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 3

    if Gem::Version.new(Gem::RubyGemsVersion) >= Gem::Version.new('1.2.0') then
    else
    end
  else
  end
end
