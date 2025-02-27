class UsersController < ApplicationController
  def index
    @users = User.all  # Fetch all users from the database
  end
end
