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
  
  class BasicSaveable
    
    class_inheritable_accessor :all, :store_path
    
    class << self
      
      def load!
        self.all = YAML.load(File.read(store_path)) rescue nil if File.file?(store_path)
        self.all = [] unless all.is_a?(Array)
      end
      
      def save!
        load! if all.nil?
        File.open(store_path, "w+") { |f| f.write all.to_yaml }
      end
      
      def add_item(item)
        load! if all.nil?
        all << item
        save!
      end
      
    end
  end
  
  def self.SaveableClass(kind)
    klass            = Class.new(BasicSaveable)
    klass.store_path = GitAuth::GITAUTH_DIR.join("#{kind}.yml").to_s
    klass.all        = nil
    return klass
  end
end