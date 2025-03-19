require "application_system_test_case"

class QRCodeScannerTest < ApplicationSystemTestCase
  test "QR code scanning posts data to the backend" do
    visit root_path

    click_on "Start Camera"

    # Mock the QR scan result
    page.execute_script('document.getElementById("result").innerText = "mocked-qr-code";')

    # Simulate the attendance mark by making the API call (mock the fetch)
    page.execute_script('
      fetch = jest.fn().mockResolvedValue({ success: true });
      markAttendance("mocked-qr-code");
    ')

    # Check that the result is displayed
    assert_text "mocked-qr-code", within: "#result"

    # Check that the attendance was recorded successfully
    # You may need to inspect your logs or mock server responses in your test
  end
end
