require 'rubygems'

gem "thoughtbot-shoulda", ">= 2.0.0"
gem "redgreen",           ">= 1.0.0"
gem "rr",                 ">= 0.10.0"
gem "rack-test"

# Testing dependencies
require 'test/unit'
require 'shoulda'
require 'rr'
require 'redgreen' if RUBY_VERSION < "1.9"

require 'pathname'
root_directory = Pathname.new(__FILE__).dirname.join("..").expand_path
require root_directory.join("lib", "gitauth")

# Preload rack requirements
GitAuth.require_vendored 'rack'
GitAuth.require_vendored 'sinatra'
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
