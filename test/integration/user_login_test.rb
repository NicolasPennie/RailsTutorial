require 'test_helper'

class UserLoginTest < ActionDispatch::IntegrationTest
  
  def setup 
    @user = users(:michael)
    @notactivated_user = users(:notactivated_user)
  end
  
  test "invalid login" do
    get login_path
    assert_template 'sessions/new'
    post login_path, params: { session: { email: "", password: "" } }
    assert_template 'sessions/new'
    assert_not flash.empty?
    get root_path
    assert flash.empty?
  end
  
  test "valid login" do 
    get login_path
    log_in_as(@user)
    assert is_logged_in?
    assert_redirected_to @user
    follow_redirect!
    assert_template 'users/show'
    assert_select "a[href=?]", login_path, count: 0
    assert_select "a[href=?]", logout_path
    assert_select "a[href=?]", user_path(@user)
  end
  
  test "redirect home if already logged in" do
    log_in_as(@user)
    get login_path
    assert_redirected_to root_url
  end
  
  test "logout and redirect to home" do
    log_in_as(@user)
    delete logout_path
    assert_not is_logged_in?
    assert_redirected_to root_url
    follow_redirect!
    assert_select "a[href=?]", login_path
    assert_select "a[href=?]", logout_path,      count: 0
    assert_select "a[href=?]", user_path(@user), count: 0
  end
  
  test "logout from multiple windows" do
    log_in_as(@user)
    delete logout_path
    delete logout_path
    assert_not is_logged_in?
  end
  
  test "login with remember me" do
    log_in_as(@user, remember_me: '1')
    assert_equal assigns(:user).remember_token, cookies['remember_token']
  end
  
  test "login without remember me" do
    log_in_as(@user, remember_me: '1')
    log_in_as(@user, remember_me: '0')
    assert_empty cookies['remember_token']
  end
  
  test "login without activation" do
    log_in_as(@notactivated_user)
    assert_not is_logged_in?
    assert_redirected_to root_url
  end
end
