class QrcodesController < ApplicationController
    def show
      @student = Student.find_by(id: params[:id])
  
      if @student
        @qr_code = RQRCode::QRCode.new(@student.uid.to_s)  # Generate the QR code using student ID
        # Optionally, you can create an image or string representation of the QR code
      else
        flash[:error] = "Student not found"
        redirect_to students_path
      end
    end
end
  