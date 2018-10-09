require 'test_helper'

class MicropostsInterfaceTest < ActionDispatch::IntegrationTest

  def setup
    @user = users(:michael)
  end
  
  test "micropost interface" do
    log_in_as(@user)
    get root_url
    assert_select "div.pagination"
    assert_select "input[type=file]"
    # Invalid submission
    assert_no_difference 'Micropost.count' do
      post microposts_path, params: { micropost: { content: "" } }
    end
    assert_select 'div#error_explanation'
    # Valid submission
    content = "This micropost really ties the room together"
    picture = fixture_file_upload('test/fixtures/rails.png')
    assert_difference 'Micropost.count', 1 do
      post microposts_path, params: { micropost: 
                                      { content: content, 
                                        picture: picture } }
    end
    assert_not flash[:success].empty?
    assert assigns(:micropost).picture?
    assert_redirected_to root_url
    follow_redirect!
    assert_match content, response.body
    # Delete micropost
    assert_select 'a', text: 'delete'
    first_post = @user.microposts.first
    assert_difference 'Micropost.count', -1 do
      delete micropost_path(first_post)
    end
    # Visit other user
    get user_path(users(:archer))
    assert_select 'a', text: 'delete', count: 0
  end
  
  test "micropost sidebar count" do
    log_in_as @user
    get root_path
    assert_match "#{@user.microposts.count} microposts", response.body
    nopost_user = users(:nopost_user)
    log_in_as nopost_user
    assert nopost_user.microposts.empty?
    get root_url
    assert_match "0 microposts", response.body
    nopost_user.microposts.create!(content: "valid")
    get root_url
    assert_match "1 micropost", response.body
  end
end
