vendor_dir = File.join(File.dirname(__FILE__), "vendor")

require File.join(vendor_dir, "rack", "lib", "rack")
require File.join(vendor_dir, "sinatra", "lib", "sinatra")

Sinatra::Application.default_options.merge!(
  :root   => GitAuth::BASE_DIR,
  :views  =>  GitAuth::BASE_DIR.join("views"),
  :public => GitAuth::BASE_DIR.join("public"),
  :run    => false,
  :env    => :production
)

require File.join(File.dirname(__FILE__), "lib", "gitauth")
require GitAuth::BASE_DIR.join("lib", "gitauth", "web_app")

GitAuth::Settings.setup!

output = File.open(GitAuth::Logger.default_logger_path, "a+")

STDOUT.reopen(output)
STDERR.reopen(output)

run GitAuth::WebApp.new
