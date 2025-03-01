# app/controllers/qrcodes_controller.rb
class QrcodesController < ApplicationController
  def show
    if current_user
      @qr_code = generate_qr_code(current_user.uuid)  # Generate QR code for the current user's ID
    else
      redirect_to new_session_path, alert: 'Please log in to view your QR code.'
    end
  end

  private

  def generate_qr_code(user_id)
    # Here, use a gem like 'rqrcode' to generate the QR code from the user_id
    RQRCode::QRCode.new(user_id.to_s).as_svg(
      offset: 0,
      color: '000',
      shape_rendering: 'crispEdges',
      module_size: 6,
      standalone: true
    )
  end

  def scan
  end

end
