module GitAuth
  class Group < SaveableClass(:groups)

    attr_accessor :name, :users
    
    def intialize(name)
      @name  = name
      @users = []
    end
    
    def add_member(user)
      @users << user.name if user.is_a?(GitAuth::Users)
      @users.uniq!
    end
    
    def member?(user)
      @users.include?(user.name) 
    end
    
    def to_s
      "@#{name}"
    end
    
    def self.get(name)
      GitAuth.logger.debug "Getting group named #{name.inspect}"
      real_name = name.to_s.gsub(/^@/, "")
      self.all.detect { |g| g.name == real_name }
    end
    
    def self.group?(name)
      name.to_s =~ /^@/ && !get(name).nil?
    end
    
  end
end