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


module GitAuth
  class Users
    
    USERS_PATH = File.join(GitAuth::GITAUTH_DIR, "users.yml")
    
    def self.all
      @@all_users ||= nil
    end
    
    def self.load!
      self.all = YAML.load_file(USERS_PATH) rescue nil if File.exist?(USERS_PATH)
      self.all = [] unless self.all.is_a?(Array)
    end
    
    def self.save!
      load! if self.all.nil?
      File.open(USERS_PATH, "w+") do |f|
        f.write self.all.to_yaml
      end
    end
    
    def self.all=(value)
      @@all_users = value
    end
    
    def self.get(name)
      GitAuth.logger.debug "Getting user for the name '#{name}'"
      self.all.detect { |r| r.name == name }
    end
    
    def self.create(name, admin, key)
      user = self.new(name, admin)
      if user.write_ssh_key!(key)
        self.load!
        self.all << user
        self.save!
        return true
      else
        return false
      end
    end
    
    attr_reader :name, :admin
    
    def initialize(name, admin = false)
      @name = name
      @admin = admin
    end
    
    def write_ssh_key!(key)
      cleaned_key = clean_ssh_key(key)
      if cleaned_key.nil?
        return false
      else
        gitauth_path = GitAuth.settings.shell_executable
        output = "command=\"#{gitauth_path} #{@name}\",no-port-forwarding,no-X11-forwarding,no-agent-forwarding#{shell_accessible? ? "" : ",no-pty"} #{cleaned_key}"
        File.open(GitAuth.settings.authorized_keys_file, "a+") do |file|
          file.puts output
        end
        return true
      end
    end
    
    def admin?
      !!@admin
    end
    
    def shell_accessible?
      admin?
    end
    
    def pushable?(repo)
      admin? || repo.writeable_by?(self)
    end
    
    def pullable?(repo)
      admin? || repo.readable_by?(self)
    end
    
    def can_execute?(command, repo)
      return nil if command.bad?
      if command.write?
        GitAuth.logger.debug "Checking if #{self.name} can push to #{repo.name}"
        return self.pushable?(repo)
      else
        GitAuth.logger.debug "Checking if #{self.name} can pull from #{repo.name}"
        return self.pullable?(repo)
      end
    end
    
    def clean_ssh_key(key)
      if key =~ /^(ssh-\w+ [a-zA-Z0-9\/\+]+==) .*$/
        return $1
      else
        return nil
      end
    end
    
  end
end