class PagesController < ApplicationController
  def home
    if user_signed_in?
      @books = Book.all
      render 'home_logged_in'
    else
      @books = Book.all
      render 'home_logged_in'
    end
  end
end
