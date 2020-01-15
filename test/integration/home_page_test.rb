# frozen_string_literal: true

require 'test_helper'

# Integration test for the Auto Numbers index
class HomePageTest < ActionDispatch::IntegrationTest
  test 'home page can be retrieved' do
    get '/'
    assert_response :success
  end
end
