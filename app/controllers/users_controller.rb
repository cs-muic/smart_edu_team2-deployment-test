class UsersController < ApplicationController
    def index
      @users = User.all
    end
  
    def edit
      @user = User.find(params[:id])
    end
  
    def update
      @user = User.find(params[:id])
      
      # Debugging: Check what params we are getting
      logger.debug "User Params: #{params[:user]}"
  
      if @user.update(user_params)
        redirect_to users_path, notice: "User role updated successfully"
      else
        render :edit
      end
    end
  
    private
  
    def user_params
      params.require(:user).permit(:role)
    end
  end
  