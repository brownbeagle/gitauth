#--
#   Copyright (C) 2009 Brown Beagle Software
#   Copyright (C) 2009 Darcy Laycock <sutto@sutto.net>
#
#   This program is free software: you can redistribute it and/or modify
#   it under the terms of the GNU Affero General Public License as published by
#   the Free Software Foundation, either version 3 of the License, or
#   (at your option) any later version.
#
#   This program is distributed in the hope that it will be useful,
#   but WITHOUT ANY WARRANTY; without even the implied warranty of
#   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#   GNU Affero General Public License for more details.
#
#   You should have received a copy of the GNU Affero General Public License
#   along with this program.  If not, see <http://www.gnu.org/licenses/>.
#++

require 'pathname'
require 'ostruct'

module GitAuth
  
  VERSION     = [0, 0, 4, 1]
  BASE_DIR    = Pathname.new(__FILE__).dirname.join("..").expand_path
  LIB_DIR     = BASE_DIR.join("lib", "gitauth")
  GITAUTH_DIR = Pathname.new("~/.gitauth/").expand_path
  
  # This is the first declaration because we need it so that we can
  # load a vendored version of perennial if present.
  def self.require_vendored(lib)
    vendored_path = BASE_DIR.join("vendor", lib, "lib", "#{lib}.rb")
    if File.exist?(vendored_path)
      $:.unshift File.dirname(vendored_path)
      require lib
    else
      require 'rubygems' unless defined?(Gem)
      require lib
    end
  end
  
  require_vendored 'perennial'
  include Perennial
  include Loggable
  
  require LIB_DIR.join("settings")
  
  %w(message saveable_class repo user command client group).each do |file|
    require LIB_DIR.join(file)
  end
  
  autoload :AuthSetupMiddleware, LIB_DIR.join('auth_setup_middleware').to_s
  autoload :WebApp,              LIB_DIR.join('web_app').to_s
  
  manifest do |m, l|
    Settings.root                  = File.dirname(__FILE__)
    Settings.default_settings_path = GITAUTH_DIR.join("settings.yml")
    Logger.default_logger_path     = GITAUTH_DIR.join("gitauth.log")
    l.before_run { GitAuth.each_model(:load!) }
    l.register_controller :web_app, 'GitAuth::WebApp'
  end
  
  class << self
    
    def prepare
      Settings.setup
      reload_models!
    end
    
    def version
      VERSION.join(".")
    end
    
    def msg(type, message)
      Message.new(type, message)
    end

    def get_user_or_group(name)
      name = name.to_s.strip
      return if name.empty?
      (name =~ /^@/ ? Group : User).get(name)
    end

    def has_git?
      !`which git`.blank?
    end

    def each_model(method = nil, &blk)
      [Repo, User, Group].each { |m| m.send(method) } if method.present?
      [Repo, User, Group].each(&blk) unless blk.nil?
    end
    
    def reload_models!
      each_model(:load!)
    end
    
    def run(command)
      GitAuth::Logger.info "Running command: #{command}"
      result = system "#{command} 2> /dev/null 1> /dev/null"
      GitAuth::Logger.info "Command was #{"not " if !result}successfull"
      return result
    end
    
  end
  
end