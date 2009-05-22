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
      @admin = false
    end
    
    def write_ssh_key!(key)
      cleaned_key = clean_ssh_key(key)
      if cleaned_key.nil?
        return false
      else
        gitauth_path = File.join(GitAuth::BASE_DIR, "bin", "gitauth-shell")
        output = "command=\"#{gitauth_path} #{@name}\",no-port-forwarding,no-X11-forwarding,no-agent-forwarding,no-pty #{cleaned_key}"
        File.open(GitAuth.settings.authorized_keys_file, "a+") do |file|
          file.puts output
        end
        return true
      end
    end
    
    def shell_accessible?
      !!@admin
    end
    
    def pushable?(repo)
      repo.writeable_by?(self)
    end
    
    def pullable?(repo)
      repo.readable_by?(self)
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