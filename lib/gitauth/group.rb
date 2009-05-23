module GitAuth
  class Group < SaveableClass(:groups)

    attr_accessor :name, :users
    
    def intialize(name)
      @name  = name
      @members = []
    end
    
    def add_member(member)
      @members << member.to_s
      @members.uniq!
    end
    
    def ==(group)
      group.is_a?(Group) && group.name == self.name
    end
    
    def member?(user_or_group)
      @members.include?(user_or_group.to_s) 
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