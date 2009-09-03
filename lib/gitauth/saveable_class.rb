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
  def self.SaveableClass(kind)
    klass = Class.new
    path_name = "#{kind.to_s.upcase}_PATH"
    yaml_file_name = "#{kind}.yml"
    
    saveable_class_def = <<-END
    
      #{path_name} = GitAuth::GITAUTH_DIR.join(#{yaml_file_name.inspect})

      class << self
    
        def all
          @@all_#{kind} ||= nil
        end
      
        def all=(value)
          @@all_#{kind} = value
        end
      
        def load!
          self.all = YAML.load_file(#{path_name}) rescue nil if File.exist?(#{path_name})
          self.all = [] unless self.all.is_a?(Array)
        end

        def save!
          load! if self.all.nil?
          File.open(#{path_name}, "w+") do |f|
            f.write self.all.to_yaml
          end
        end
      
        def .add_item(item)
          self.load! if self.all.nil?
          self.all << item
          self.save!
        end
    
      end
    
    END
    klass.class_eval(saveable_class_def)
    return klass
  end
end