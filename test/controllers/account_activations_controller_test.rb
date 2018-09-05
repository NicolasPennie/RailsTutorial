require 'test_helper'

class AccountActivationsControllerTest < ActionDispatch::IntegrationTest
  def setup
    post signup_path, params: { user: { name: "Valid Name",
                                          email: "user@valid.com",
                                          password: "foobar",
                                          password_confirmation: "foobar" } }
    @notactivated_user = assigns(:user)
  end
  
  test "invalid activation token; valid email" do
    user = @notactivated_user
    get edit_account_activation_path("invalid token", email: user.email)
    assert_not user.reload.activated?
    assert_not flash[:danger].empty?
  end
  
  test "valid activation token; invalid email" do
    user = @notactivated_user
    get edit_account_activation_path(user.activation_token, email: "invalid email")
    assert_not user.reload.activated?
    assert_not flash[:danger].empty?
  end
  
  test "valid activation token" do
    user = @notactivated_user
    get edit_account_activation_path(user.activation_token, email: user.email)
    assert user.reload.activated?
    assert_not flash[:success].empty?
    assert_redirected_to login_path
  end
end
