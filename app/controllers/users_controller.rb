class UsersController < ApplicationController
    def index
      @users = User.all
    end

    def edit
      @user = User.find(params[:id])
    end

    def update
        @user = User.find(params[:id])

        # Detailed debugging
        logger.debug "User before update: #{@user.attributes.inspect}"
        logger.debug "User Params: #{params[:user]}"

        if @user.update(user_params)
          logger.debug "User after update: #{@user.attributes.inspect}"
          redirect_to users_path, notice: "User role updated successfully"
        else
          logger.debug "User update failed: #{@user.errors.full_messages}"
          render :edit
        end
    end

    private

    def user_params
      params.require(:user).permit(:role)
    end
end
