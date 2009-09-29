require 'fileutils'
require 'digest/sha2'

module GitAuth
  class ApacheAuthentication
    PUBLIC_DIR = GitAuth::BASE_DIR.join("public")
    
    class << self
      
      def setup?
        PUBLIC_DIR.join(".htaccess").file? && PUBLIC_DIR.join(".htpasswd").file?
      end
      
      def setup
        GitAuth::WebApp.check_auth
        puts "To continue, we require you re-enter the password you wish to use."
        raw_password  = ''
        password_hash = ''
        existing_hash = GitAuth::Settings.web_password_hash
        while raw_password.blank? && password_hash != existing_hash
          raw_password  = read_password('GitAuth Password: ')
          password_hash = sha256_password(raw_password)
          if raw_password.blank?
            puts "You need to provide a password, please try again"
          elsif password_hash != existing_hash
            puts "Your password doesn't match the stored password. Please try again."
          end
        end
        raw_username = GitAuth::Settings.web_username
        encoded_password = "{SHA}#{[Digest::SHA1.digest(raw_password)].pack('m').strip}"
        File.open(PUBLIC_DIR.join(".htpasswd"), "w+") do |file|
          file.puts "#{raw_username}:#{encoded_password}"
        end
        File.open(PUBLIC_DIR.join(".htaccess"), "w+") do |file|
          file.puts "AuthType Basic"
          file.puts "AuthName \"GitAuth\""
          file.puts "AuthUserFile #{PUBLIC_DIR.join(".htpasswd").expand_path}"
          file.puts "Require valid-user"
        end
      end
      
      def remove
        PUBLIC_DIR.join(".htaccess").delete
        PUBLIC_DIR.join(".htpasswd").delete
      rescue Errno::ENOENT
      end
      
      protected
      
      def read_password(text)
        system "stty -echo" 
        password = Readline.readline(text)
        system "stty echo"
        print "\n"
        return password
      end
      
      def sha256_password(pass)
        Digest::SHA256.hexdigest(pass)
      end
      
    end
  end
end