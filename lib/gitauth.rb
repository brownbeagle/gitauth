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

# Prepend lib dir + any vendored lib's to the front of the load
# path to ensure they're loaded first.
$LOAD_PATH.unshift(*Dir[Pathname(__FILE__).dirname.join("../{lib,vendor/*/lib}").expand_path])

require 'perennial'

module GitAuth
  include Perennial
  include Loggable
  
  VERSION     = [0, 0, 5, 2]
  BASE_DIR    = Pathname(__FILE__).dirname.join("..").expand_path
  GITAUTH_DIR = Pathname("~/.gitauth/").expand_path
  
  manifest do |m, l|
    Settings.root                  = File.dirname(__FILE__)
    Settings.default_settings_path = GITAUTH_DIR.join("settings.yml")
    Settings.lookup_key_path       = []
    Logger.default_logger_path     = GITAUTH_DIR.join("gitauth.log")
    # Register stuff on the loader.
    l.register_controller :web_app, 'GitAuth::WebApp'
    l.before_run { GitAuth.prepare }
  end
  
  require 'gitauth/message'        # Basic error messages etc (as of yet unushed)
  require 'gitauth/saveable_class' # Simple YAML store for dumpables classes
  require 'gitauth/repo'           # The basic GitAuth repo object
  require 'gitauth/user'           # The basic GitAuth user object
  require 'gitauth/group'          # The basic GitAuth group object (collection of users)
  require 'gitauth/command'        # Processes / filters commands
  require 'gitauth/client'         # Handles the actual SSH interaction / bringing it together
  
  autoload :AuthSetupMiddleware,  'gitauth/auth_setup_middleware'
  autoload :ApacheAuthentication, 'gitauth/apache_authentication'
  autoload :WebApp,               'gitauth/web_app'
  
  class << self
    
    def prepare
      GitAuth::Settings.setup!
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
      GitAuth::Logger.info "Command was #{"not " if !result}successful"
      return result
    end
    
  end
  
end