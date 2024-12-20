require 'ostruct'

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

  def admin
    @user = User.find(params[:id])
    @users = User.all
    if (params[:first_query].present?)
      @users = @users.select{|user| user[:first].to_s.downcase.include?(params[:first_query].downcase)}
    end
    if (params[:last_query].present?)
      @users = @users.select{|user| user[:last].to_s.downcase.include?(params[:last_query].downcase)}
    end
    if (params[:email_query].present?)
      @users = @users.select{|user| user[:email].to_s.downcase.include?(params[:email_query].downcase)}
    end
  end

  def admin_moderate
    @user = User.find(params[:id])
    @reviews = @user.reviews
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

  def destroy
    @user = User.find(params[:id])
    @user.friendships.destroy_all
    if @user.destroy
      if (params[:from_admin].present? && params[:from_admin])
        redirect_to user_admin_path(1)
      else
        redirect_to books_path
      end
    else
      ##error message
    end

  end

  private
  def create_update_params
    params.require(:user).permit(:first, :last, :email, :bio)
  end


end
