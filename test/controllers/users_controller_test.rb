require 'test_helper'

class UsersControllerTest < ActionDispatch::IntegrationTest
  
  def setup
    @user = users(:michael)
    @other_user = users(:archer)
    @notactivated_user = users(:notactivated_user)
  end
  
  test "should get new" do
    get signup_path
    assert_response :success
    assert_select "title", full_title("Sign up")
  end
  
  test "should get index" do
    log_in_as(@user)
    get users_path
    assert_response :success
    assert_select "title", full_title("All users")
   end
  
  test "should redirect edit when not logged in" do
    get edit_user_path(@user)
    assert_not flash.empty?
    assert_redirected_to login_url
  end
  
  test "should redirect update when not logged in" do
    patch user_path(@user), params: { user: { name: @user.name,
                                             email: @user.email } }
    assert_not flash.empty?
    assert_redirected_to login_url
  end
  
  test "should redirect edit when logged in as other user" do
    log_in_as(@other_user)
    get edit_user_path(@user)
    assert flash.empty?
    assert_redirected_to root_url
  end
  
  test "should redirect update when logged in as other user" do
    log_in_as(@other_user)
    patch user_path(@user), params: { user: { name: @user.name,
                                             email: @user.email } }
    assert flash.empty?
    assert_redirected_to root_url
  end
  
  test "should redirect edit with friendly forwarding" do
    get edit_user_path(@user)
    log_in_as(@user)
    assert_redirected_to edit_user_path(@user)
    get user_path(@user)
    log_in_as(@user)
    assert session[:forwarding_url].nil?
    assert_redirected_to user_path(@user), 
      "assert not redirected back after second login"
  end
  
  test "should redirect index when not logged in" do
    get users_path
    assert_redirected_to login_url
  end
  
  test "should not allow the admin attribute to be edited via the web" do
    log_in_as(@other_user)
    assert_not @other_user.admin?
    patch user_path(@other_user), params: {
                                    user: { password:              "",
                                            password_confirmation: "",
                                            admin: true 
                                            } }
    assert_not @other_user.reload.admin?
  end
  
  test "should not allow delete when not logged in" do
    assert_no_difference 'User.count', "User should not be deleted" do 
      delete user_path(@other_user)
    end
    assert_redirected_to login_url
  end
  
  test "should not allow delete for non-admin" do
    log_in_as(@other_user)
    assert_not @other_user.admin?
    assert_no_difference 'User.count', "User should not be deleted" do 
      delete user_path(@user)
    end
    assert_redirected_to root_url
  end
  
  test "successful destroy" do
    log_in_as(@user)
    get users_path
    assert_difference 'User.count', -1, "User should not be deleted" do 
      delete user_path(@other_user)
    end
    assert_redirected_to users_path
  end
  
  test "should not find invalid user" do
    invalid_id = User.count + 1
    # show
    get user_path(id: invalid_id)
    assert_redirected_to root_url
    assert_not flash.empty?
    # edit
    get edit_user_path(id: invalid_id)
    assert_redirected_to root_url
    assert_not flash.empty?
    # update
    patch user_path(id: invalid_id)
    assert_redirected_to root_url
    assert_not flash.empty?
    # destroy 
    delete user_path(id: invalid_id)
    assert_redirected_to root_url
    assert_not flash.empty?
  end
  
  test "should not find unactivated user" do
    get user_path(@notactivated_user)
    assert_redirected_to root_url
  end
end
