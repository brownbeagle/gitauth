#--
#   Copyright (C) 2009 Brown Beagle Software
#   Copyright (C) 2009 Darcy Laycock <sutto@sutto.net>
#
#   This program is free software: you can redistribute it and/or modify
#   it under the terms of the GNU Affero General Public License as published by
#   the Free Software Foundation, either version 3 of the License, or
#   (at your option) any later version.
#
#   This program is distributed in the hope that it will be useful,
#   but WITHOUT ANY WARRANTY; without even the implied warranty of
#   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#   GNU Affero General Public License for more details.
#
#   You should have received a copy of the GNU Affero General Public License
#   along with this program.  If not, see <http://www.gnu.org/licenses/>.
#++


module GitAuth
  class Group < SaveableClass(:groups)
    include GitAuth::Loggable
    
    attr_accessor :name, :members
    
    def initialize(name)
      @name  = name
      @members = []
    end
    
    def destroy!
      GitAuth::Repo.all.each { |r| r.remove_permissions_for(self) }
      self.class.all.each { |r| r.remove_member(self) }
      self.class.all.reject! { |g| g == self }
      GitAuth::Repo.save!
      self.class.save!
    end
    
    def add_member(member)
      return if member == self
      @members << member.to_s
      @members.uniq!
    end
    
    def remove_member(member)
      @members.reject! { |m| m == member.to_s }
    end
    
    def ==(group)
      group.is_a?(Group) && group.name == self.name
    end
    
    def member?(user_or_group, recurse = false, level = 0)
      member = @members.include?(user_or_group.to_s)
      Thread.current[:checked_groups] = [] if level == 0
      if !member
        return false if level > 0 && Thread.current[:checked_groups].include?(self)
        Thread.current[:checked_groups] << self
        member = recurse && @members.map { |m| Group.get(m) }.compact.any? { |g| g.member?(user_or_group, true, level + 1) } 
      end
      Thread.current[:checked_groups] = nil if level == 0
      return member
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
      logger.debug "Getting group named #{name.inspect}"
      real_name = name.to_s.gsub(/^@/, "")
      self.all.detect { |g| g.name == real_name }
    end
    
    def self.group?(name)
      name.to_s =~ /^@/ && !get(name).nil?
    end
    
  end
end