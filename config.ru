require File.join(File.dirname(__FILE__), "lib", "gitauth")
require GitAuth::BASE_DIR.join("lib", "gitauth", "web_app")

GitAuth::Settings.setup!
run GitAuth::WebApp.new
