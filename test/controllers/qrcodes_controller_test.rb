require "test_helper"

class QrcodesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:one)
  end

  test "should redirect guest users from show" do
    get qrcode_url
    assert_redirected_to new_session_path
    follow_redirect!
    assert_match /Please log in to view your QR code/, response.body
  end

  test "should show QR code for logged-in user" do
    sign_in @user
    get qrcode_url
    assert_response :success
    assert_match /<svg/, response.body
  end
end
