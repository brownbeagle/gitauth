require 'test_helper'

class AuthSetupMiddlewareTest < Test::Unit::TestCase
  
  context '' do
  
    setup do
      @original_app = GitAuth::WebApp.new
      @middleware = GitAuth::AuthSetupMiddleware.new(@original_app)
      app_is @middleware
    end
  
    should 'pass through to the main app is there is authentication information' do
      mock(GitAuth::WebApp).has_auth? { true }.times(any_times)
      mock(@original_app).call(is_a(Hash)) { |env| GitAuth::WebApp.new.call(env) }
      get '/'
      assert_equal 401, last_response.status
    end
  
    should 'use Rack::File for the css if authentication is not setup' do
      mock(GitAuth::WebApp).has_auth? { false }.times(any_times)
      dont_allow(@original_app).call(is_a(Hash)) { |env| GitAuth::WebApp.new.call(env) }
      get '/gitauth.css'
      assert_equal 200, last_response.status
    end
  
    should 'render a text message for other files if authentication is not setup' do
      mock(GitAuth::WebApp).has_auth? { false }.times(any_times)
      dont_allow(@original_app).call(is_a(Hash)) { |env| GitAuth::WebApp.new.call(env) }
      get '/'
      assert_equal 403, last_response.status
    end
    
  end
  
end