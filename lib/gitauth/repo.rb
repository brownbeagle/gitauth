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

require 'fileutils'
module GitAuth
  class Repo < SaveableClass(:repositories)
    NAME_RE = /^([\w\_\-\.\+]+(\.git)?)$/i
    
    def self.get(name)
      GitAuth::Logger.debug "Getting Repo w/ name: '#{name}'"
      (all || []).detect { |r| r.name == name }
    end
    
    def self.create(name, path = name)
      return false if name.nil? || path.nil?
      return false if self.get(name) || self.all.any? { |r| r.path == path } || name !~ NAME_RE || path !~ NAME_RE
      repository = new(name, path)
      return false unless repository.create_repo!
      add_item(repository)
      repository
    end
    
    attr_accessor :name, :path, :permissions
    
    def initialize(name, path, auto_create = false)
      @name, @path = name, path
      @permissions = {}
    end
    
    def ==(other)
      other.is_a?(Repo) && other.name == name && other.path == path
    end
    
    def writeable_by(whom)
      add_permissions :write, whom
    end
    
    def readable_by(whom)
      add_permissions :read, whom
    end
    
    def update_permissions!(user, permissions = [])
      remove_permissions_for(user)
      writeable_by(user) if permissions.include?("write")
      readable_by(user)  if permissions.include?("read")
      self.class.save!
    end
    
    def writeable_by?(user_or_group)
      has_permissions_for :write, user_or_group
    end
    
    def readable_by?(user_or_group)
      has_permissions_for :read, user_or_group
    end
    
    def remove_permissions_for(user_or_group)
      @permissions.each_value do |val|
        val.reject! { |m| m == user_or_group.to_s }
      end
    end
    
    def real_path
      File.join(GitAuth::Settings.base_path, @path)
    end
    
    def create_repo!
      return false if !GitAuth.has_git?
      unless File.directory?(real_path)
        FileUtils.mkdir_p(real_path)
        output = ""
        Dir.chdir(real_path) { IO.popen("git --bare init") { |f| output << f.read } }
        !!(output =~ /Initialized empty Git repository/)
      end
    end
    
    def destroy!
      FileUtils.rm_rf(real_path) if File.exist?(real_path)
      self.class.all.reject! { |r| r == self }
      self.class.save!
    end
    
    def make_empty!
      tmp_path = "/tmp/gitauth-#{rand(100000)}-#{Time.now.to_i}"
      GitAuth::Logger.info "Creating temporary dir at #{tmp_path}"
      FileUtils.mkdir_p("#{tmp_path}/current-repo")
      GitAuth::Logger.info "Changing to new directory"
      Dir.chdir("#{tmp_path}/current-repo") do
        GitAuth::Logger.info "Marking as git repo"
        GitAuth.run "git init"
        GitAuth::Logger.info "Touching .gitignore"
        GitAuth.run "touch .gitignore"
        # Configure it
        GitAuth.run "git config push.default current"
        GitAuth::Logger.info "Commiting"
        GitAuth.run "git commit -am 'Initialize Empty Repository'"
        # Push the changes to the actual repository
        GitAuth::Logger.info "Adding origin #{self.real_path}"
        GitAuth.run "git remote add origin '#{self.real_path}'"
        GitAuth::Logger.info "Pushing..."
        GitAuth.run "git push origin master"
      end
    ensure
      GitAuth::Logger.info "Cleaning up old tmp file"
      FileUtils.rm_rf(tmp_path) if File.directory?(tmp_path)
    end
    
    def execute_post_create_hook!
      script = File.expand_path("~/.gitauth/post-create")
      if File.executable?(script)
        system(script, @name, @path)
        return $?.success?
      else
        # If there isn't a file, run it ourselves.
        return true
      end
    end
    
    protected
    
    def add_permissions(type, whom)
      @permissions[type] ||= []
      @permissions[type] << whom.to_s
      @permissions[type].uniq!
    end
    
    def has_permissions_for(type, whom)
      whom = GitAuth.get_user_or_group(whom) if whom.is_a?(String)
      GitAuth::Logger.info "Checking if #{whom.to_s} can #{type} #{self.name}"
      !(@permissions[type] || []).detect do |reader|
        reader = GitAuth.get_user_or_group(reader)
        reader == whom || (reader.is_a?(Group) && reader.member?(whom, true))
      end.nil?
    end
    
  end
end