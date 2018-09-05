require 'test_helper'

class UserSignupTest < ActionDispatch::IntegrationTest

  def setup
    ActionMailer::Base.deliveries.clear
  end
  
  test "signup form" do
    get signup_path
    assert_select 'form[action="/signup"]'
  end
  
  test "invalid user signup" do
    get signup_path
    assert_no_difference 'User.count' do
      post signup_path, params: { user: { name: "",
                                       email: "user@invalid",
                                       password: "foo",
                                       password_confirmation: "bar" } }
    end
    assert_template 'users/new'
    assert_select "div#error_explanation" do
      assert_select "div.alert" 
      assert_select "ul" do
        assert_select "li", 4
      end
    end
  end
  
  
  test "valid user signup with account activation" do
    get signup_path
    assert_difference "User.count", 1 do
      post signup_path, params: { user: { name: "Valid Name",
                                          email: "user@valid.com",
                                          password: "foobar",
                                          password_confirmation: "foobar" } }
    end
    # Redirect to root
    assert_redirected_to root_url
    assert_not flash.empty?, "Check activation email"
    # Send email
    assert_equal 1, ActionMailer::Base.deliveries.size
    assert_not assigns(:user).activated?
  end
end