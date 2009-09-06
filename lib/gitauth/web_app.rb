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

# Preload Rack and sinatra. Do so in this order so
# that we can ensure the load path is 'correct'
GitAuth.require_vendored 'rack'
GitAuth.require_vendored 'sinatra'

require 'digest/sha2'
module GitAuth
  class WebApp < Sinatra::Base
    include logger
    
    cattr_accessor :current_server
    
    def self.has_auth?
      username = GitAuth::Settings["web_username"]
      password = GitAuth::Settings["web_password_hash"]
      !(username.blank? || password.blank?)
    end
    
    def self.update_auth
      raw_username = Readline.readline('GitAuth Username (default is \'gitauth\'): ')
      raw_username = 'gitauth' if raw_username.blank?
      raw_password = ''
      while raw_password.blank?
        system "stty -echo" 
        raw_password = Readline.readline('GitAuth Password: ')
        system "stty echo"
        print "\n"
        puts "You need to provide a password, please try again" if raw_password.blank?
      end
      GitAuth::Settings.update!({
        :web_username      => raw_username,
        :web_password_hash => Digest::SHA256.hexdigest(raw_password)
      })
    end
    
    def self.check_auth
      if !has_auth?
        if $stderr.tty?
          logger.verbose = true 
          puts "For gitauth to continue, you need to provide a username and password."
          update_auth
        else
          logger.fatal "You need to provide a username and password for GitAuth to function; Please run 'gitauth webapp` once"
          exit!
        end
      end
    end
    
    def self.run(options = {})
      check_auth
      set options
      handler      = detect_rack_handler
      handler_name = handler.name.gsub(/.*::/, '')
      logger.info "Starting up web server on #{port}"
      handler.run self, :Host => host, :Port => port do |server|
        GitAuth::WebApp.current_server = server
        set :running, true
      end
    rescue Errno::EADDRINUSE => e
      logger.fatal "Server is already running on port #{port}"
    end
    
    def self.stop
      if current_server.present?
        current_server.respond_to?(:stop!) ? current_server.stop! : current_server.stop
      end
      logger.debug "Stopped Server."
    end
    
    use GitAuth::AuthSetupMiddleware
    
    use Rack::Auth::Basic do |username, password|
      [username, Digest::SHA256.hexdigest(password)] == [GitAuth::Settings["web_username"], GitAuth::Settings["web_password_hash"]]
    end
    
    configure do
      set :port, 8998
      set :views,  GitAuth::BASE_DIR.join("views")
      set :public, GitAuth::BASE_DIR.join("public")
      set :static, true
      set :methodoverride, true
    end
    
    before { GitAuth.reload_models! }
    
    helpers do
      include Rack::Utils
      alias_method :h, :escape_html
      
      def link_to(text, link)
        "<a href='#{link}'>#{text}</a>"
      end
      
      def delete_link(text, url)
        id = "deleteable-#{Digest::SHA256.hexdigest(url.to_s)[0, 6]}"
        html =  "<div class='deletable-container' style='display: none; margin: 0; padding: 0;'>"
        html << "<form method='post' action='#{url}' id='#{id}'>"
        html << "<input name='_method' type='hidden' value='delete' />"
        html << "</form></div>"
        html << "<a href='#' onclick='if(confirm(\"Are you sure you want to do that? Deletion can not be reversed.\")) $(\"##{id}\").submit(); return false;'>#{text}</a>"
        return html
      end
      
      def auto_link(member)
        member = member.to_s
        url = (member[0] == ?@ ? "/groups/#{URI.encode(member[1..-1])}" : "/users/#{URI.encode(member)}")
        return link_to(member, url)
      end
      
    end
    
    get '/' do
      @repos  = GitAuth::Repo.all
      @users  = GitAuth::User.all
      @groups = GitAuth::Group.all
      erb :index
    end
    
    # Listing / Index Page
    
    get '/repos/:name' do
      @repo = GitAuth::Repo.get(params[:name])
      if @repo.nil?
        redirect root_with_message("The given repository couldn't be found.")
      else
        read_perms, write_perms = (@repo.permissions[:read]||[]), (@repo.permissions[:write]||[])
        @all_access = read_perms & write_perms
        @read_only  = read_perms - @all_access 
        @write_only = write_perms - @all_access
        erb :repo
      end
    end
    
    get '/users/:name' do
      @user = GitAuth::User.get(params[:name])
      if @user.nil?
        redirect root_with_message("The given user couldn't be found.")
      else
        repos  = GitAuth::Repo.all 
        read_perms  = repos.select { |r| r.readable_by?(@user)  }
        write_perms = repos.select { |r| r.writeable_by?(@user) }
        @all_access = read_perms & write_perms
        @read_only  = read_perms - @all_access
        @write_only = write_perms - @all_access
        @groups = GitAuth::Group.all.select { |g| g.member?(@user) }
        erb :user
      end
    end
    
    get '/groups/:name' do
      @group = GitAuth::Group.get(params[:name])
      if @group.nil?
        redirect root_with_message("The given group could not be found.")
      else
        erb :group
      end
    end
    
    # Create and update repos
    
    post '/repos' do
      name = params[:repo][:name]
      path = params[:repo][:path]
      path = name if path.to_s.strip.empty?
      if repo = GitAuth::Repo.create(name, path)
        if repo.execute_post_create_hook!
          redirect "/?repo_name=#{URI.encode(name)}"
        else
          redirect root_with_message("Repository added but the post-create hook exited unsuccessfully.")
        end
      else
        redirect root_with_message("There was an error adding the repository.")
      end
    end
    
    post '/repos/:name' do
      repo = GitAuth::Repo.get(params[:name])
      if repo.nil?
        redirect root_with_message("The given repository couldn't be found.")
      else
        new_permissions = Hash.new([])
        [:all, :read, :write].each do |k|
          if params[:repo][k]
            perm_lines = params[:repo][k].to_s.split("\n")
            new_permissions[k] = perm_lines.map do |l|
              i = GitAuth.get_user_or_group(l.strip)
              i.nil? ? nil : i.to_s
            end.compact
          end
        end
        all = new_permissions.delete(:all)
        new_permissions[:read]  |= all
        new_permissions[:write] |= all
        new_permissions.each_value { |v| v.uniq! }
        repo.permissions = new_permissions
        GitAuth::Repo.save!
        redirect "/repos/#{URI.encode(repo.name)}"
      end
    end
    
    delete '/repos/:name' do
      repo = GitAuth::Repo.get(params[:name])
      if repo.nil?
        redirect root_with_message("The given repository couldn't be found.")
      else
        repo.destroy!
        redirect root_with_message("Repository removed.")
      end
    end
    
    # Create, delete and update users
    
    post '/users' do
      name  = params[:user][:name]
      admin = params[:user][:admin].to_s == "1"
      key   = params[:user][:key]
      if GitAuth::User.create(name, admin, key)
        redirect root_with_message("User Added")
      else
        redirect root_with_message("There was an error adding the requested user.")
      end
    end
    
    delete '/users/:name' do
      user = GitAuth::User.get(params[:name])
      if user.nil?
        redirect root_with_message("The specified user couldn't be found.")
      else
        user.destroy!
        redirect root_with_message("User removed.")
      end
    end
    
    # Create and Update Groups
    
    post '/groups' do
      if GitAuth::Group.create(params[:group][:name])
        redirect root_with_message("Group added")
      else
        redirect root_with_message("There was an error adding the requested group.")
      end
    end
    
    post '/groups/:name' do
      group = GitAuth::Group.get(params[:name])
      if group.nil?
        redirect root_with_message("The specified group couldn't be found.")
      else
        if params[:group][:members]
          member_lines = params[:group][:members].to_s.split("\n")
          group.members = member_lines.map do |l|
            i = GitAuth.get_user_or_group(l.strip)
            i.nil? ? nil : i.to_s
          end.compact - [group.to_s]
          GitAuth::Group.save!
        end
        redirect "/groups/#{URI.encode(group.name)}"
      end
    end
    
    delete '/groups/:name' do
      group = GitAuth::Group.get(params[:name])
      if group.nil?
        redirect root_with_message("The specified group couldn't be found.")
      else
        group.destroy!
        redirect root_with_message("Group removed.")
      end
    end
    
    # Misc Helpers
    
    def root_with_message(message)
      "/?message=#{URI.encode(message)}"
    end
    
  end
end