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


module GitAuth
  class User < SaveableClass(:users)
    include GitAuth::Loggable

    SSH_KEY_REGEX = /ssh-\w+ [a-zA-Z0-9\/\+]+=?=?/

    def self.get(name)
      logger.debug "Getting user for the name '#{name}'"
      (all || []).detect { |r| r.name == name }
    end

    def self.create(name, admin, key)
      # Basic sanity checking
      return false if name.nil? || admin.nil? || key.nil?

      # Require that the name is valid and admin is a boolean.
      return false unless name =~ /^([\w\_\-\.]+)$/ && !!admin == admin

      # Check there isn't an existing user
      return false unless get(name).blank?

      user = User.new(name, admin)
      if user.add_key_or_file!(key)
        add_item(user)
        return user
      else
        return nil
      end
    end

    attr_reader :name, :admin

    def initialize(name, admin = false)
      @name = name
      @admin = admin
    end

    def to_s
      @name.to_s
    end

    def command_prefix
      options  = ["command=\"#{GitAuth::Settings.shell_executable} #{@name}\"",
                  "no-port-forwarding", "no-X11-forwarding", "no-agent-forwarding"]
      options << "no-pty" if !shell_accessible?
      options.join(",")
    end

    ##
    # Destroys the user. This means all information about this user
    # will be removed from the database files (keys, group
    # associations, permissions).
    def destroy!
      # Clear permissions.
      GitAuth::Repo.all.each  { |r| r.remove_permissions_for(self) }

      # Clear group associations.
      GitAuth::Group.all.each { |g| g.remove_member(self) }

      # Remove public keys from the authorized_keys file.
      clear_all_keys!

      # Remove this user object from the list of users.
      self.class.all.reject! { |u| u == self }

      # Finally, save everything.
      self.class.save!
      GitAuth::Repo.save!
      GitAuth::Group.save!
    end

    ##
    # Retrieves all groups, that this user is part of.
    def groups
      (Group.all || []).select { |g| g.member?(self) }
    end

    ##
    # Reads the SSH keys for the current user
    # from the authorization file.
    def keys
      unless @keys
        @keys = {}
        File.open(GitAuth::Settings.authorized_keys_file, 'r') do |file|
          while (line = file.gets)
            if line =~ /^#{command_prefix} (#{SSH_KEY_REGEX}) (.+)$/
              @keys[$2] = $1
            end
          end
        end
      end
      @keys
    end

    ##
    # Removes all SSH keys for this users
    def clear_all_keys!
      keys.clear
      write_keys!
    end

    ##
    # Checks whether the given argument is an existing file or not.
    # If yes, read the files contents and try adding the content as a
    # new key. Otherwise add the argument as a new key.
    def add_key_or_file arg
      if File.exists?(arg)
        add_key File.read(arg)
      else
        add_key key
      end
    end

    ##
    # Adds key or file and then saves authorized_keys file.
    def add_key_or_file! arg
      add_key_or_file(arg) and write_keys!
    end

    ##
    # Adds a key to the set of keys for this user. If a user already
    # had this key associated, it gets updated.
    def add_key key
      if key =~ /^(#{SSH_KEY_REGEX}) (.+)$/
        if (old_key = keys.key($1))
          keys[$2] = keys.delete(old_key)
        else
          keys[$2] = $1
        end
        return true
      end
      return false
    end

    ##
    # Adds the key and saves the authorized_keys file.
    def add_key! key
      add_key(key) and write_keys!
    end

    ##
    # Removes the key from the user.
    # Valid key arguments may be the key itself or the name of the key.
    def remove_key key
      if key =~ /^#{SSH_KEY_REGEX}$/
        if (old_key = keys.key($1))
          keys.delete(old_key)
          return true
        end
      else
        if keys[key]
          keys.delete(key)
          return true
        end
      end
      return false
    end

    ##
    # Removes the key and saves the authorized_keys file.
    def remove_key! key
      remove_key(key) and write_keys!
    end

    ##
    # Write all keys to file.
    def write_keys!
      begin
        keyset = []
        File.open(GitAuth::Settings.authorized_keys_file, "r") do |file|
          while (line = file.gets)
            if line !~ /^#{command_prefix}/ and line =~ /#{SSH_KEY_REGEX} .+/
              keyset << line
            end
          end
        end
        keys.each_pair do |name, key|
          keyset << "#{command_prefix} #{key} #{name}\n"
        end
        File.open(GitAuth::Settings.authorized_keys_file, "w+") do |file|
          file.puts "## GitAuth - DO NO EDIT BELOW THIS LINE ##"
          file.puts keyset.join
        end
        return true
      rescue Exception => e
        puts "Some error happened while saving authorized_keys file: #{e}"
        return false
      end
    end

    def admin?
      !!@admin
    end

    alias shell_accessible? admin?

    def pushable?(repo)
      admin? || repo.writeable_by?(self)
    end

    def pullable?(repo)
      admin? || repo.readable_by?(self)
    end

    def can_execute?(command, repo)
      return if command.bad?
      if command.write?
        logger.debug "Checking if #{self.name} can push to #{repo.name}"
        pushable?(repo)
      else
        logger.debug "Checking if #{self.name} can pull from #{repo.name}"
        pullable?(repo)
      end
    end

    def self.valid_key?(key)
      key.present? && key =~ /^#{SSH_KEY_REGEX} .+$/
    end
  end
  Users = User # For Backwards Compat.
end
