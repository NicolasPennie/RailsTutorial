require 'test_helper'

class PasswordResetsTest < ActionDispatch::IntegrationTest

  def setup
    post password_resets_path params: { password_reset: { email: 
                                                users(:michael).email } }
    @user = assigns(:user)
    ActionMailer::Base.deliveries.clear
  end
  
  test "should get password reset" do
    get new_password_reset_path
    assert_template 'password_resets/new'
  end
  
  test "request reset with invalid email" do
    post password_resets_path params: { password_reset: { email: "" } }
    assert_select 'div#error_explanation'
    assert_template 'password_resets/new'
  end
  
  test "request reset with valid email" do
    post password_resets_path params: { password_reset: { email: @user.email } }
    assert_not flash[:info].empty?
    assert_redirected_to root_url
    assert_equal 1, ActionMailer::Base.deliveries.size
  end
  
  test "follow link with valid token; invalid email" do
    get edit_password_reset_path(@user.reset_token, email: "invalid email")
    assert_not flash[:danger].empty?
    assert_redirected_to root_url
  end
  
  test "follow link with valid token; valid email; non-activated user" do
    user = @user
    user.toggle!(:activated)
    get edit_password_reset_path(user.reset_token, email: user.email)
    assert_not flash[:danger].empty?
    assert_redirected_to root_url
  end
  
  test "follow link with invalid token; valid email" do
    get edit_password_reset_path("invalid token", email: @user.email)
    assert_not flash[:danger].empty?
    assert_redirected_to root_url
  end
  
  test "expired link with valid email/token" do
    user = @user
    expired_time = Time.now - (User::RESET_EXPIRY_AGE + 1.hour)
    user.update_attribute(:reset_sent_at, expired_time)
    get edit_password_reset_path(@user.reset_token, email: @user.email)
    assert_not flash[:danger].empty?
    assert_redirected_to new_password_reset_path
  end
  
  test "follow link with valid token; valid email" do
    get edit_password_reset_path(@user.reset_token, email: @user.email)
    assert_template 'password_resets/edit'
    assert_select "input[name=email][type=hidden][value=?]", @user.email
  end
  
  test "invalid password change" do
    patch password_reset_path(@user.reset_token), params: { 
                                              email: @user.email,
                                              user: {
                                                password: "foobar",
                                                password_confirmation: "barfoo"
                                              } }
    assert_template 'password_resets/edit'
    assert_select 'div#error_explanation'
  end
  
  test "blank password change" do
    patch password_reset_path(@user.reset_token), params: { 
                                              email: @user.email,
                                              user: {
                                                password: "",
                                                password_confirmation: ""
                                              } }
    assert_template 'password_resets/edit'
    assert_select 'div#error_explanation'
  end
  
  test "valid password change" do
    patch password_reset_path(@user.reset_token), params: { 
                                              email: @user.email,
                                              user: {
                                                password: "foobar",
                                                password_confirmation: "foobar"
                                              } }
    assert @user.reload.reset_digest.nil?
    assert_redirected_to @user
    assert_not flash[:success].empty?
    # ensure reset link is no longer functional
    get edit_password_reset_path(@user.reset_token, email: @user.email)
    assert_not flash[:danger].empty?
    assert_redirected_to root_url
  end
end
