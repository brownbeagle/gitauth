#--
#   Copyright (C) 2009 Brown Beagle Software
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
  class Repo < SaveableClass(:repositories)
    NAME_RE    = /^([\w\_\-\.\+]+(\.git)?)$/i
    
    def self.get(name)
      GitAuth.logger.debug "Getting Repo w/ name: '#{name}'"
      self.all.detect { |r| r.name == name }
    end
    
    def self.create(name, path = name)
      return false if name.nil? || path.nil?
      return false if self.get(name) || self.all.any? { |r| r.path == path } || name !~ NAME_RE || path !~ NAME_RE
      repository = self.new(name, path)
      return false unless repository.create_repo!
      self.add_item(repository)
      return true
    end
    
    attr_accessor :name, :path
    
    def initialize(name, path, auto_create = false)
      @name, @path = name, path
      @permissions = {}
    end
    
    def ==(other)
      other.is_a?(Repo) && other.name == name && other.path == 
    end
    
    def writeable_by(user_or_group)
      @permissions[:write] ||= []
      @permissions[:write] << user_or_group.to_s
      @permissions[:write].uniq!
    end
    
    def readable_by(user_or_group)
      @permissions[:read] ||= []
      @permissions[:read] << user_or_group.to_s
      @permissions[:read].uniq!
    end
    
    def writeable_by?(user_or_group)
      !(@permissions[:write] || []).detect do |writer|
        writer = GitAuth.get_user_or_group(writer)
        writer == user_or_group || (writer.is_a?(Group) && writer.member?(user_or_group))
      end.nil?
    end
    
    def readable_by?(user_or_group)
      !(@permissions[:read] || []).detect do |reader|
        reader = GitAuth.get_user_or_group(reader)
        reader == user_or_group || (reader.is_a?(Group) && reader.member?(user_or_group))
      end.nil?
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
    
    def destroy!
      FileUtils.rm_rf(self.real_path) if File.exist?(self.real_path)
      self.all.reject! { |r| r == self }
      self.class.save!
    end
    
  end
end