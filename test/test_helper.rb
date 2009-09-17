require 'rubygems'

if defined?(Gem)
  # Check the versions of the gems we're loading
  # just to be sure
  gem "thoughtbot-shoulda", ">= 2.0.0"
  gem "redgreen",           ">= 1.0.0"
  gem "rr",                 ">= 0.10.0"
  gem "rack-test"
end

# Testing dependencies
require 'test/unit'
require 'shoulda'
require 'rr'
require 'redgreen' if RUBY_VERSION < "1.9"

require 'pathname'
require Pathname(__FILE__).dirname.join("..").expand_path.join("lib", "gitauth")

# Misc. app dependencies
require 'rack'
require 'sinatra'
require 'rack/test'

class Test::Unit::TestCase

  include RR::Adapters::TestUnit
  include Rack::Test::Methods
  
  protected
  
  def app
    @app ||= GitAuth::WebApp
  end
  
  def app_is(app)
    @app = app
  end
  
  # Short hand for creating a class with
  # a given class_eval block.
  def class_via(*args, &blk)
    klass = Class.new(*args)
    klass.class_eval(&blk) unless blk.blank?
    return klass
  end
  
  # Short hand for creating a test class
  # for a set of mixins - give it the modules
  # and it will include them all.
  def test_class_for(*mods, &blk)
    klass = Class.new
    klass.class_eval { include(*mods) }
    klass.class_eval(&blk) unless blk.blank?
    return klass
  end
  
end
