module GitAuth
  class Client
    
    attr_accessor :user, :command
    
    def initialize(user_name, command)
      GitAuth.logger.debug "Initializing client with command: '#{command}' and user name '#{user_name}'"
      @callbacks = Hash.new { |h,k| h[k] = [] }
      @user      = GitAuth::Users.get(user_name.to_s.strip)
      @command   = command
    end
    
    def on(command, &blk)
      @callbacks[command.to_sym] << blk
    end
    
    def execute_callback!(command)
      @callbacks[command.to_sym].each { |c| c.call(self) }
    end
    
    def exit_with_error(error)
      GitAuth.logger.warn "Exiting with error: #{error}"
      $stderr.puts error
      exit! 1
    end
    
    def run!
      if @user.nil?
        execute_callback! :invalid_user
      elsif @command.to_s.strip.empty?
        execute_callback! :invalid_command
      else
        command   = Command.parse!(@command)
        repo      = Repo.get(extract_repo_name(command))
        if command.bad?
          execute_callback! :bad_command
        elsif repo.nil?
          execute_callback! :invalid_repository
        elsif user.can_execute?(command, repo)
          # We can go ahead.
          git_shell_argument = "#{command.verb} '#{repo.real_path}'"
          # And execute that soab.
          GitAuth.logger.info "Running command: #{git_shell_argument} for user: #{@user.name}"
          exec("git-shell", "-c", git_shell_argument)
        else
          execute_callback! :access_denied
        end
      end
    rescue Exception => e
      GitAuth.logger.fatal "Exception: #{e.class.name}: #{e.message}"
      e.backtrace.each do |l|
        GitAuth.logger.fatal "  => #{l}"
      end
      execute_callback! :fatal_error
    end
    
    def self.start!(user, command)
      client = self.new(user, command)
      yield client if block_given?
      client.run!
    end
    
    protected
    
    def extract_repo_name(command)
      command.path.gsub(/\.git$/, "")
    end
    
  end
end