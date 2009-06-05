Gem::Specification.new do |s|
  s.name = %q{gitauth}
  s.version = "0.0.3.1"
  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Darcy Laycock", "Alex Pooley", "Matt Didcoe"]
  s.date = %q{2009-04-05}
  s.default_executable = %q{gitauth}
  s.description = %q{Git Authentication Server}
  s.email = %q{sutto@sutto.net}
  s.executables = ["gitauth", "gitauth-shell"]
  s.extra_rdoc_files = ["README.rdoc", "LICENSE"]
  s.files = ["bin/gitauth", "bin/gitauth-shell", "lib/gitauth/client.rb", "lib/gitauth/command.rb", "lib/gitauth/group.rb", "lib/gitauth/repo.rb", "lib/gitauth/saveable_class.rb", "lib/gitauth/user.rb", "lib/gitauth/web_app.rb", "lib/gitauth.rb", "LICENSE", "public/gitauth.css", "public/gitauth.js", "public/jquery.js", "README.rdoc", "views/group.erb", "views/index.erb", "views/layout.erb", "views/repo.erb", "views/user.erb"]
  
  
  s.has_rdoc = false
  s.homepage = "http://github.com/brownbeagle/gitauth"
  s.rdoc_options = ["--inline-source", "--charset=UTF-8"]
  s.require_paths = ["lib"]
  s.rubygems_version = %q{1.3.1}
  s.summary = %q{Git Authentication Server}

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 2
    if Gem::Version.new(Gem::RubyGemsVersion) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<thor>, [">= 0.9.7"])
      s.add_runtime_dependency(%q<sinatra>, [">= 0.9"])
    else
      s.add_dependency(%q<thor>, [">= 0.9.7"])
      s.add_dependency(%q<sinatra>, [">= 0.9"])
    end
  else
    s.add_dependency(%q<thor>, [">= 0.9.7"])
    s.add_dependency(%q<sinatra>, [">= 0.9"])
  end
end
