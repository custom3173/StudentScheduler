require 'test_helper'

class AccessControllerTest < ActionController::TestCase
  test "should get retrieve_user" do
    get :retrieve_user
    assert_response :success
  end

  test "should get verify" do
    get :verify
    assert_response :success
  end

  test "should get create_user" do
    get :create_user
    assert_response :success
  end

end
