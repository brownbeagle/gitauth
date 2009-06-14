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
      return repository
    end
    
    attr_accessor :name, :path, :permissions
    
    def initialize(name, path, auto_create = false)
      @name, @path = name, path
      @permissions = {}
    end
    
    def ==(other)
      other.is_a?(Repo) && other.name == name && other.path == path
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
        writer == user_or_group || (writer.is_a?(Group) && writer.member?(user_or_group, true))
      end.nil?
    end
    
    def readable_by?(user_or_group)
      !(@permissions[:read] || []).detect do |reader|
        reader = GitAuth.get_user_or_group(reader)
        reader == user_or_group || (reader.is_a?(Group) && reader.member?(user_or_group, true))
      end.nil?
    end
    
    def remove_permissions_for(user_or_group)
      @permissions.each_value do |val|
        val.reject! { |m| m == user_or_group.to_s }
      end
    end
    
    def real_path
      File.join(GitAuth.settings.base_path, @path)
    end
    
    def create_repo!
      return false if !GitAuth.has_git?
      path = self.real_path
      unless File.exist?(path) && File.directory?(path)
        FileUtils.mkdir_p(path)
        output = ""
        Dir.chdir(path) do
          IO.popen("git --bare init") { |f| output << f.read }
        end
        return !!(output =~ /Initialized empty Git repository/)
      end
    end
    
    def destroy!
      FileUtils.rm_rf(self.real_path) if File.exist?(self.real_path)
      self.class.all.reject! { |r| r == self }
      self.class.save!
    end
    
    def make_empty!
      tmp_path = "/tmp/gitauth-#{rand(100000)}-#{Time.now.to_i}"
      FileUtils.mkdir(tmp_path)
      system('git clone', self.real_path, "#{tmp_path}/current-repo")
      Dir.chdir("#{tmp_path}/current-repo") do
        IO.popen("touch .gitignore && git commit -am 'Initial Empty Repository' && git push origin master") { |f| f.read }
      end
      FileUtils.rm_rf(tmp_path)
    end
    
    def execute_post_create_hook!
      script = File.expand_path("~/.gitauth/post-create")
      if File.exist?(script) && File.executable?(script)
        system(script, @name, @path)
        return $?.success?
      else
        # If there isn't a file, run it ourselves.
        return true
      end
    end
    
  end
end