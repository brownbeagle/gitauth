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


require 'logger'
require 'yaml'
require 'ostruct'
require 'pathname'

module GitAuth
  
  BASE_DIR    = Pathname.new(__FILE__).dirname.join("..").expand_path
  GITAUTH_DIR = Pathname.new("~/.gitauth/").expand_path
  
  class << self
    
    def logger
      @logger ||= ::Logger.new(GITAUTH_DIR.join("gitauth.log"))
    end

    def settings
      @settings ||= OpenStruct.new(YAML.load_file(GITAUTH_DIR.join("settings.yml")))
    end

    def reload_settings
      @settings = nil
    end

    def get_user_or_group(name)
      name = name.to_s.strip
      return if name.empty?
      (name =~ /^@/ ? Group : User).get(name)
    end

    def has_git?
      !`which git`.strip.empty?
    end

    def setup!
      unless File.exist?(GITAUTH_DIR) && File.directory?(GITAUTH_DIR)
        $stderr.puts "GitAuth not been setup, please run `gitauth install`"
        exit! 1
      end
      dir = BASE_DIR.join("lib", "gitauth")
      %w(saveable_class repo user command client group).each do |file|
        require dir.join(file)
      end
      # Load the users and repositories from a YAML File.
      self.each_model { |m| m.load! }
    end

    def serve_web
      self.setup!
      require BASE_DIR.join("lib", "gitauth", "web_app")
      GitAuth::WebApp.run!
    end

    def force_setup
      @settings = nil
      self.each_model { |m| m.all = nil }
      self.setup!
    end

    def each_model(&blk)
      [Repo, User, Group].each(&blk)
    end
    
  end
  
end