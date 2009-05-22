#--
#   Copyright (C) 2009 BrownBeagle
#   Copyright (C) 2008 Darcy Laycock <sutto@sutto.net>
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

module GitAuth
  
  BASE_DIR      = File.expand_path(File.join(File.dirname(__FILE__), ".."))
  GITAUTH_DIR   = File.expand_path("~/.gitauth/")
  
  def self.logger
    @logger ||= ::Logger.new(File.join(GITAUTH_DIR, "gitauth.log"))
  end
  
  def self.settings
    @settings ||= OpenStruct.new(YAML.load_file(File.join(GITAUTH_DIR, "settings.yml")))
  end
  
  def self.setup!
    unless File.exist?(GITAUTH_DIR) && File.directory?(GITAUTH_DIR)
      $stderr.puts "GitAuth not been setup, please run: gitauth install"
      exit! 1
    end
    dir = File.expand_path(File.join(File.dirname(__FILE__), "gitauth"))
    %w(repo users command client).each do |file|
      require File.join(dir, file)
    end
    # Load the users and repositories from a YAML File.
    GitAuth::Repo.load!
    GitAuth::Users.load!
  end
  
end