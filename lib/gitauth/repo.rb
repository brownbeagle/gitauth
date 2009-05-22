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