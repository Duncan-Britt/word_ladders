ENV["RACK_ENV"] = "test"

require "minitest/autorun"
require 'minitest/reporters'
require "rack/test"
Minitest::Reporters.use!

require_relative '../app.rb'

class ExampleTest < Minitest::Test
  include Rack::Test::Methods

  def app
    Sinatra::Application
  end

  def setup
  end

  def teardown
  end

  def session
    last_request.env["rack.session"]
  end

  def test_runs
    get '/'
    session[:foo]
    assert_equal true, true
  end
end
