require 'logger'
require 'yaml'
require 'ostruct'

module GitAuth
  
  BASE_DIR      = File.expand_path(File.join(File.dirname(__FILE__), ".."))
  GITAUTH_DIR   = File.expand_path("~/.gitauth/")
  
  def self.logger
    @logger ||= ::Logger.new(File.join(GITAUTH_DIR, "access.log"))
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