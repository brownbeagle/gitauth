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
  class AuthSetupMiddleware
    
    def initialize(app)
      @app = app
      @files = Rack::File.new(GitAuth::BASE_DIR.join("public").to_s)
    end
    
    def call(env)
      dup._call(env)
    end
    
    def _call(env)
      if GitAuth::WebApp.has_auth?
        @app.call(env)
      elsif env["PATH_INFO"].include?("/gitauth.css")
        @files.call(env)
      else
        content = ERB.new(File.read(GitAuth::BASE_DIR.join("views", "auth_setup.erb"))).result
        headers = {"Content-Type" => "text/html", "Content-Length" => Rack::Utils.bytesize(content).to_s}
        [403, headers, [content]]
      end
    end
    
  end
end