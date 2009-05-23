module GitAuth
  class Group < SaveableClass(:groups)

    attr_accessor :name, :members
    
    def initialize(name)
      @name  = name
      @members = []
    end
    
    def destroy!
      GitAuth::Repo.all.each { |r| r.remove_permissions_for(self) }
      self.class.all.reject! { |g| g == self }
      GitAuth::Repo.save!
      self.class.save!
    end
    
    def add_member(member)
      @members << member.to_s
      @members.uniq!
    end
    
    def remove_member(member)
      @members.reject! { |m| m == member.to_s }
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
    
    def self.create(name)
      name = name.to_s.strip.gsub(/^@/, "")
      return false if name.empty? || name !~ /^([\w\_\-\.]+)$/
      self.add_item self.new(name)
      return true
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