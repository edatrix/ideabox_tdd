require './test/test_helper'
require 'bundler'
Bundler.require
require 'rack/test'
require 'capybara'
require 'capybara/dsl'

require './lib/app'

Capybara.app = IdeaboxApp

Capybara.register_driver :rack_test do |app|
  Capybara::RackTest::Driver.new(app, :headers =>  { 'User-Agent' => 'Capybara' })
end

class IdeaManagementTest < Minitest::Test
  include Capybara::DSL

  def teardown
    IdeaStore.delete_all
  end

  def test_manage_ideas
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


end
