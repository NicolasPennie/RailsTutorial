require 'test_helper'
require 'sessions_helper'

class SiteLayoutTest < ActionDispatch::IntegrationTest
  
  def setup 
    @user = users(:michael)
  end
  
  test "layout links" do
    get root_path
    assert_template 'static_pages/home'
    assert_select "a[href=?]", root_path, count: 2
    assert_select "a[href=?]", help_path
    assert_select "a[href=?]", about_path
    assert_select "a[href=?]", contact_path
    assert_select "a[href=?]", signup_path
    
    get help_path
    assert_template 'static_pages/help'
    
    get about_path
    assert_template 'static_pages/about'
    
    get contact_path
    assert_template 'static_pages/contact'
    
    get signup_path
    assert_template 'users/new'
  end
  
  test "signed-in layout links" do
    log_in_as(@user)
    get root_path   
        assert_template 'static_pages/home'
    assert_select "a[href=?]", root_path, count: 2
    assert_select "a[href=?]", help_path
    assert_select "a[href=?]", users_path, "Users"
    assert_select "a[href=?]", user_path(@user), "Profile"
    assert_select "a[href=?]", edit_user_path(@user), "Settings"
    assert_select "a[href=?]", about_path
    assert_select "a[href=?]", contact_path
  end
end
