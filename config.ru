require File.join(File.dirname(__FILE__), "lib", "gitauth")
require GitAuth::BASE_DIR.join("lib", "gitauth", "web_app")

GitAuth::Settings.setup!

output = File.open(GitAuth::Logger.default_logger_path, "a+")
STDOUT.reopen(output)
STDERR.reopen(output)

{:root => GitAuth::BASE_DIR, :run => false, :env => :production}.each_pair do |key, value|
  GitAuth::WebApp.configure do
    set key, value
  end
end

run GitAuth::WebApp.new
