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