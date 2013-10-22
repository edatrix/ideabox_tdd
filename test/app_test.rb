require './test/test_helper'
require 'sinatra/base'
require 'rack/test'
require './lib/app'

class IdeaboxAppTest < Minitest::Unit::TestCase
  include Rack::Test::Methods

  def app
    IdeaboxApp
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

  def test_manage_ideas
    # skip
    # Create a couple of decoys
    # This is so we know we're editing the right thing later
    IdeaStore.save Idea.new("laundry", "buy more socks")
    IdeaStore.save Idea.new("groceries", "macaroni, cheese")

    # Create an idea
    visit '/'
    # The decoys are there
    assert page.has_content?("buy more socks"), "Decoy idea (socks) is not on page"
    assert page.has_content?("macaroni, cheese"), "Decoy idea (macaroni) is not on page"

    # Fill in the form
    fill_in 'title', :with => 'eat'
    fill_in 'description', :with => 'chocolate chip cookies'
    click_button 'Save'
    assert page.has_content?("chocolate chip cookies"), "Idea is not on page"

    # Find the idea - we need the ID to find
    # it on the page to edit it
    idea = IdeaStore.find_by_title('eat')

    # Edit the idea
    within("#idea_#{idea.id}") do
      click_link 'Edit'
    end

    assert_equal 'eat', find_field('title').value
    assert_equal 'chocolate chip cookies', find_field('description').value

    fill_in 'title', :with => 'eats'
    fill_in 'description', :with => 'chocolate chip oatmeal cookies'
    click_button 'Save'

    # Idea has been updated
    assert page.has_content?("chocolate chip oatmeal cookies"), "Updated idea is not on page"

    # Decoys are unchanged
    assert page.has_content?("buy more socks"), "Decoy idea (socks) is not on page after update"
    assert page.has_content?("macaroni, cheese"), "Decoy idea (macaroni) is not on page after update"

    # Original idea (that got edited) is no longer there
    refute page.has_content?("chocolate chip cookies"), "Original idea is on page still"

    # Delete the idea
    within("#idea_#{idea.id}") do
      click_button 'Delete'
    end

    refute page.has_content?("chocolate chip oatmeal cookies"), "Updated idea is not on page"

    # Decoys are untouched
    assert page.has_content?("buy more socks"), "Decoy idea (socks) is not on page after delete"
    assert page.has_content?("macaroni, cheese"), "Decoy idea (macaroni) is not on page after delete"
  end

  def test_delete_idea
    id = IdeaStore.save Idea.new('breathe', 'fresh air in the mountains')

    assert_equal 1, IdeaStore.count

    delete "/#{id}"

    assert_equal 302, last_response.status
    assert_equal 0, IdeaStore.count
  end

end
