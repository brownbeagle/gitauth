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
  class Settings < Perennial::Settings
   
    def self.setup!(options = {})
      @@configuration = {}
      settings_file = self.default_settings_path
      if File.exist?(settings_file)
        loaded_yaml = YAML.load(File.read(settings_file))
        # We don't use the default namespace etc.
        @@configuration.merge!(loaded_yaml || {})
      end
      @@configuration.merge! options
      @@configuration.symbolize_keys!
      # Generate a module 
      mod = generate_settings_accessor_mixin
      extend  mod
      include mod
      @@setup = true
    end
    
    def self.update!(hash)
      settings_file = self.default_settings_path
      settings = File.file?(settings_file) ? YAML.load(File.read(settings_file)) : {}
      hash.each_pair { |k,v| settings[k.to_s] = v }
      File.open(settings_file, "w+") { |f| f.write(settings.to_yaml) }
      setup!
    end
    
  end
end