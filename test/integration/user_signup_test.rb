require 'test_helper'

class UserSignupTest < ActionDispatch::IntegrationTest
  test "invalid user signup" do
    get signup_path
    assert_select 'form[action="/signup"]'
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
end
