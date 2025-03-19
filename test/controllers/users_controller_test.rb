require "test_helper"

class UsersControllerTest < ActionDispatch::IntegrationTest
  # test "the truth" do
  #   assert true
  # end

  setup do
    @user = users(:one)
    sign_in(:adminA)
  end

  test "should get index" do
    get users_url
    assert_response :success
  end

  test "should get new" do
    get new_user_url
    assert_response :success
  end

  test "should create user" do
    assert_difference("User.count") do
      post users_url, params: { user: { email_address: "newuser@a1.com", password: "aaaaaaaa", password_confirmation: "aaaaaaaa", role: "teacher" } }
    end

    assert_redirected_to user_url(User.last)
  end

  test "should show user" do
    get user_url(@user)
    assert_equal @controller.user.id, @user.id
    assert_response :success
  end

  test "should get edit" do
    get edit_user_url(@user)
    assert_response :success
  end

  test "should update user" do
    patch user_url(@user), params: { user: { role: "student" } }
    assert_redirected_to users_url
  end

  # test "should destroy user" do
  #   assert_difference("User.kept.count", -1) do
  #     delete user_url(@user)
  #   end

  #   assert_redirected_to users_url
  # end

  test "should not be able to access user index without admin roles" do
    sign_in(:teacherA)
    get users_url
    assert_redirected_to root_path
    assert_equal "You must be an admin to access requested page.", flash[:alert]

    sign_in(:studentA)
    get users_url
    assert_redirected_to root_path
    assert_equal "You must be an admin to access requested page.", flash[:alert]
  end
end
