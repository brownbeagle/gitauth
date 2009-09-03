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
