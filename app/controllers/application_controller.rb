class ApplicationController < ActionController::Base
  include Authentication
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  # allow_browser versions: :modern
  def current_user
    @current_user ||= User.find_by(id: session[:user_id]) if session[:user_id]
  end
  helper_method :current_user  # Make it accessible in views
  # check the user's role
  def require_admin
    unless admin?
      flash[:alert] = "You must be an admin to access requested page."
      redirect_to root_path
    end
  end

  def require_owner
    unless owner?
      flash[:alert] = "You must be an owner to access requested page."
      redirect_to root_path
    end
  end

  def require_teacher
    unless teacher?
      flash[:alert] = "You must be a teacher to access requested page."
      redirect_to root_path
    end
  end

  def require_student
    unless student?
      flash[:alert] = "You must be a student to access requested page."
      redirect_to root_path
    end
  end

  def require_unassigned
    unless unassigned?
      flash[:alert] = "You must be an unassigned to access requested page."
      redirect_to root_path
    end
  end

  helper_method :admin?, :teacher?, :student?

  def admin?
    current_user&.role == "admin"
  end

  def owner?
    current_user&.role == "owner"
  end

  def teacher?
    current_user&.role == "teacher"
  end

  def student?
    current_user&.role == "student"
  end

  def unassigned?
    current_user&.role == "unassigned"
  end
end
