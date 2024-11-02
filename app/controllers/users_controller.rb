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
      redirect_to user_path(@user)
      #add notices and flashes to everything
    else 
      render :edit, status: :unprocessable_content
    end
  end

  def create
    @user = User.new(create_update_params)
    if @user.save
      flash[:message] = "Successfully created user #{@user.first} #{@user.last}"
    else
      flash[:message] = "Unable to create user. Please try again"
    end
    redirect_to users_path
  end

  def new
    @user = User.new
  end

  def destroy
    @user = User.find(params[:id])
    if @user.destroy
      redirect_to users_path
    else
      ##error message
    end

  end

  private
  def create_update_params
    params.require(:user).permit(:first, :last, :email, :bio)
  end


end
