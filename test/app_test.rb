require './test/test_helper'
require 'sinatra/base'
require 'rack/test'
require './lib/app'

class IdeaboxAppTest < Minitest::Unit::TestCase
  include Rack::Test::Methods

  def app
    IdeaboxApp
  end

  def teardown
    IdeaStore.delete_all
  end

  def test_create_idea
    post '/', title: 'costume', description: "scary vampire"

    assert_equal 1, IdeaStore.count

    idea = IdeaStore.all.first
    assert_equal "costume", idea.title
    assert_equal "scary vampire", idea.description
  end

  def test_edit_idea
    id = IdeaStore.save Idea.new('sing', 'happy songs')

    put "/#{id}", {title: 'yodle', description: 'joyful songs'}

    assert_equal 302, last_response.status

    idea = IdeaStore.find(id)
    assert_equal 'yodle', idea.title
    assert_equal 'joyful songs', idea.description
  end



  def test_delete_idea
    id = IdeaStore.save Idea.new('breathe', 'fresh air in the mountains')

    assert_equal 1, IdeaStore.count

    delete "/#{id}"

    assert_equal 302, last_response.status
    assert_equal 0, IdeaStore.count
  end

end
