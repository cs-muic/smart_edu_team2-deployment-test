class UsersController < ApplicationController
  before_action :set_user, only: %i[ show edit update destroy ]
  before_action :set_user, only: [ :show, :edit, :update, :destroy ]
  attr_reader :user # helps with testing
  attr_reader :users
  include Pagy::Backend
  # GET /users or /users.json
  def index
    @pagy, @users = pagy(User.kept)
  end

  # GET /users/1 or /users/1.json
  def show
    @user = User.kept.find(params[:id]) # Fetch the user by ID from the database
    respond_to do |format|
      format.html { render "show" }
      format.js
      format.json { render json: @user.slice(:id, :created_at, :updated_at) }
    end
  end

  # GET /users/new
  def new
    @user = User.new
  end

  # GET /users/1/edit
  def edit
  end

  def edit; end
  # POST /users or /users.json
  def create
    @user = User.new(user_params)

    respond_to do |format|
      if @user.save
        format.html { redirect_to @user, notice: "User was successfully created." }
        format.json { render :show, status: :created, location: @user }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /users/1 or /users/1.json
  def update
    respond_to do |format|
      if @user.update(user_params)
        format.html { redirect_to @user, notice: "User was successfully updated." }
        format.json { render :show, status: :ok, location: @user }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /users/1 or /users/1.json
  def destroy
    @user.discard!

    respond_to do |format|
      format.html { redirect_to users_path, status: :see_other, notice: "#{@user.email_address} was successfully removed." }
      format.json { head :no_content }
    end
  end

  private

    rescue_from ActiveRecord::RecordInvalid, with: :render_unprocessable_entity_response
    rescue_from ActiveRecord::RecordNotFound, with: :render_not_found_response

    def render_unprocessable_entity_response(exception)
      render json: exception.record.errors, status: :unprocessable_entity
    end

    def render_not_found_response(exception)
      render json: { error: exception.message }, status: :not_found
    end

    # Use callbacks to share common setup or constraints between actions.
    def set_user
      @user = User.find(params.expect(:id))
      @user = User.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def user_params
      params.require(:user).permit(:email_address, :password, :password_confirmation)
    end
end
