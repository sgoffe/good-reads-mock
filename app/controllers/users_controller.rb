class UsersController < ApplicationController

  def index
    @users = User.all.order(:first)
  end

  def show
    @user = User.find(params[:id])
  end

  def edit
    @user = User.find(params[:id])
  end

  def update
    @user = User.find(params[:id])
    if @user.update(create_update_params)
      redirect to user_path(@user)
      #add notices and flashes to everything
    else 
      render :edit, status: :unprocessable_content
  end

  def create
    @user = User.new(create_update_params)
    if @user.save
      redirect_to users_path
    else
      render :new, status: :unprocessable_content
  end

  def new
    @user = User.new
  end

  def destroy
    @user = User.find(params[:id])
    @user.destroy!
  end

  private
  def create_update_params
    params.require(:user).permit(:first, :last, :email, :bio)
  end


end
