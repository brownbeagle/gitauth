require 'yaml'

module GitAuth
  class Message
    
    TEMPLATES = YAML.load_file(BASE_DIR.join("resources", "messages.yml"))
    
    attr_accessor :type, :name, :message, :variables
    
    def initialize(type, name, variables = {})
      @type      = type
      @name      = name
      @variables = {}
      variables.each_pair { |k,v| @variables[k.to_s] = v }
      auto_set_message!
    end
    
    def success?
      @type.to_sym == :notice
    end
    
    def error?
      @type.to_sym == :error
    end
    
    class << self
      # Handy accessor / generate methods
      # for a given error code.
      
      def error(name = :unknown)
        new(:error, name)
      end
    
      def notice(name = :unknown)
        new(:notice, name)
      end
    
      def warning(name = :unknown)
        new(:warning, name)
      end
    end
    
    protected
    
    def auto_set_message!
      raw_message = (TEMPLATES[@type.to_s] || {})[@name.to_s] || ""
      @message = raw_message.gsub(/\:(\w+)/i) { |v| @variables[$1] || "" }
    end
    
  end
end
