require 'test_helper'

class UsersIndexTest < ActionDispatch::IntegrationTest
  def setup
    @user = users(:michael)
    @other_user = users(:archer)
  end

  test "index including pagination" do
    log_in_as(@user)
    get users_path
    assert_template 'users/index'
    assert_select 'div.pagination', count: 2
    User.paginate(page: 1).each do |user|
      assert_select 'a[href=?]', user_path(user), text: user.name
    end
  end
  
  test "successful destroy" do
    log_in_as(@user)
    get users_path
    assert_difference 'User.count', -1, "User should not be deleted" do 
      delete user_path(@other_user)
    end
    assert_redirected_to users_path
  end
end
