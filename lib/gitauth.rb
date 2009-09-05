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
  
  VERSION     = [0, 0, 4, 0]
  BASE_DIR    = Pathname.new(__FILE__).dirname.join("..").expand_path
  GITAUTH_DIR = Pathname.new("~/.gitauth/").expand_path
  
  # This is the first declaration because we need it so that we can
  # load a vendored version of perennial if present.
  def self.require_vendored(lib)
    vendored_path = BASE_DIR.join("vendor", lib, "lib", "#{lib}.rb")
    if File.exist?(vendored_path)
      require vendored_path
    else
      require 'rubygems' unless defined?(Gem)
      require lib
    end
  end
  
  require_vendored 'perennial'
  include Perennial
  include Loggable
  
  manifest do |m, l|
    Settings.root                  = File.dirname(__FILE__)
    Settings.default_settings_path = GITAUTH_DIR.join("settings.yml")
    Logger.default_logger_path     = GITAUTH_DIR.join("gitauth.log")
    l.before_run do
      GitAuth.each_model { |m| m.load! }
    end
  end
  
  has_library :message, :saveable_class, :repo, :user, :command, :client, :group
  
  autoload :WebApp, BASE_DIR.join("lib", "gitauth", "web_app")
  
  class << self
    
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
      !`which git`.strip.empty?
    end

    def serve_web
      self.setup!
      GitAuth::WebApp.run!
    end

    def each_model(&blk)
      [Repo, User, Group].each(&blk)
    end
    
  end
  
end