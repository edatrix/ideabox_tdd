require './test/test_helper'
require 'sinatra/base'
require 'rack/test'
require './lib/app'

class IdeaBoxApp < Minitest::Unit::TestCase
  include Rack::Test::Methods

  def app
    IdeaBoxApp
  end

  def test_create_idea
    post '/', title: 'costume', description: "scary vampire"

    assert_equal 1, IdeaStore.count

    idea = IdeaStore.all.first
    assert_equal "costume", idea.title
    assert_equal "scary vampire", idea.description
  end

end
