module GitAuth
  class Command
    class BadCommandError < StandardError; end
    
    # Standard Commands
    READ_COMMANDS  = ["git-upload-pack", "git upload-pack"]
    WRITE_COMMANDS = ["git-receive-pack", "git receive-pack"]
    PATH_REGEXP    = /^'([a-z0-9\-\+]+(\.git)?)'$/i.freeze
    
    attr_reader :path, :verb, :command
    
    def initialize(command)
      @command     = command
      @verb        = nil
      @argument    = nil
      @path        = nil
      @bad_command = true
    end
    
    def bad?
      !!@bad_command
    end
    
    def write?
      !bad? && @verb_type == :write
    end
    
    def read?
      !bad? && !write?
    end
    
    # These exceptions are FUGLY.
    # Clean up, mmkay?
    def process!
      raise BadCommandError if @command.include?("\n")
      @verb, @argument = split_command
      raise BadCommandError if @argument.nil? || @argument.is_a?(Array) 
      # Check if it's read / write
      if READ_COMMANDS.include?(@verb)
        @verb_type = :read
      elsif WRITE_COMMANDS.include?(@verb)
        @verb_type = :write
      else
        raise BadCommandError
      end
      if PATH_REGEXP =~ @argument
        @path = $1
        raise BadCommandError unless @path
      else
        raise BadCommandError
      end
      @bad_command = false
    rescue BadCommandError
    end
    
    def self.parse!(command)
      command = self.new(command)
      command.process!
      command
    end
    
    protected
    
    def split_command
      parts = @command.split(" ")
      if parts.size == 3
        ["#{parts[0]} #{parts[1]}", parts[2]]
      elsif parts.size == 2
        parts
      else
        raise BadCommandError
      end
    end
    
  end
end