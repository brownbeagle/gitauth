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

require 'fileutils'
module GitAuth
  class Repo
    REPOS_PATH = File.join(GitAuth::GITAUTH_DIR, "repositories.yml")
    
    def self.all
      @@all_repositories ||= nil
    end
    
    def self.load!
      self.all = YAML.load_file(REPOS_PATH) rescue nil if File.exist?(REPOS_PATH)
      self.all = [] unless self.all.is_a?(Array)
    end
    
    def self.save!
      load! if self.all.nil?
      File.open(REPOS_PATH, "w+") do |f|
        f.write self.all.to_yaml
      end
    end
    
    def self.all=(value)
      @@all_repositories = value
    end
    
    def self.get(name)
      GitAuth.logger.debug "Getting Repo w/ name: '#{name}'"
      self.all.detect { |r| r.name == name }
    end
    
    def self.create(name, path = name)
      return false unless self.get(name).nil?
      repository = self.new(name, path)
      if repository.create_repo!
        self.load!
        self.all << repository
        self.save!
        return true
      else
        return false
      end
    end
    
    attr_accessor :name, :path
    
    def initialize(name, path, auto_create = false)
      @name, @path = name, path
      @permissions = {}
    end
    
    def writeable_by(user)
      @permissions[:write] ||= []
      @permissions[:write] << user.name
      @permissions[:write].uniq!
    end
    
    def readable_by(user)
      @permissions[:read] ||= []
      @permissions[:read] << user.name
      @permissions[:read].uniq!
    end
    
    def writeable_by?(user)
      (@permissions[:write] || []).include? user.name
    end
    
    def readable_by?(user)
      (@permissions[:read] || []).include? user.name
    end
    
    def real_path
      File.join(GitAuth.settings.base_path, @path)
    end
    
    def create_repo!
      path = self.real_path
      unless File.exist?(path) && File.directory?(path)
        FileUtils.mkdir_p(path)
        output = ""
        Dir.chdir(path) do
          IO.popen("git init --bare") { |f| output << f.read }
        end
        return !!(output =~ /Initialized empty Git repository/)
      end
    end
    
  end
end