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
    # skip
    IdeaStore.save Idea.new("eat", "chocolate chip cookies")
    visit '/'
    fill_in 'title', :with => 'eat'
    fill_in 'description', :with => 'chocolate chip cookies'
    click_button 'Save'
    assert page.has_content?("chocolate chip cookies"), "Idea is not on page"
  end
end
