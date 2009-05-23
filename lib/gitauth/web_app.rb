#--
#   Copyright (C) 2009 BrownBeagle
#   Copyright (C) 2008 Darcy Laycock <sutto@sutto.net>
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

require 'sinatra'

module GitAuth
  class WebApp < Sinatra::Base
    
    use Rack::Auth::Basic do |username, password|
      [username, password] == ["gitauth", "gitauth"]
    end
    
    configure do
      set :port,   8998
      set :views,  File.join(GitAuth::BASE_DIR, "views")
      set :public, File.join(GitAuth::BASE_DIR, "public")
      set :static, true
    end
    
    before do
      GitAuth.force_setup!
    end
    
    helpers do
      include Rack::Utils
      alias_method :h, :escape_html
      
      def link_to(text, link)
        "<a href='#{link}'>#{text}</a>"
      end
      
    end
    
    get '/' do
      @repos = GitAuth::Repo.all
      @users = GitAuth::Users.all
      erb :index
    end
    
    
    # Listing / Index Page
    
    get '/repos/:name' do
      @repo = GitAuth::Repo.get(params[:name])
      if @repo.nil?
        redirect root_with_message("The given repository couldn't be found.")
      else
        erb :repo
      end
    end
    
    get '/users/:name' do
      @user = GitAuth::Users.get(params[:name])
      if @user.nil?
        redirect root_with_message("The given user couldn't be found.")
      else
        erb :user
      end
    end
    
    # Create and update repos
    
    post '/repos' do
      name = params[:repo][:name]
      path = params[:repo][:path]
      path = name if path.to_s.strip.empty?
      if GitAuth::Repo.create(name, path)
        redirect root_with_message("Repository successfully added")
      else
        redirect root_with_message("There was an error adding the repository.")
      end
    end
    
    post '/repos/:name' do
      @repo = GitAuth::Repo.get(params[:name])
      if @repo.nil?
        redirect root_with_message("The given repository couldn't be found.")
      else
      end
    end
    
    # Create and update users
    
    post '/users' do
      name  = params[:user][:name]
      admin = params[:user][:admin].to_s == "1"
      key   = params[:user][:key]
      if GitAuth::Users.create(name, admin, key)
        redirect root_with_message("User Added")
      else
        redirect root_with_message("There was an error adding that user.")
      end
    end
    
    post '/users/:name' do
      @user = GitAuth::Users.get(params[:name])
      if @user.nil?
        redirect root_with_message("The given user couldn't be found.")
      else
      end
    end
    
    def root_with_message(message)
      "/?message=#{URI.encode(message)}"
    end
    
  end
end