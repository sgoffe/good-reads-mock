class BooksController < ApplicationController
  def index
    @books = Book.all.order(:title)
  end

  def show
    @book = Book.find(params[:id])
    @reviews = @book.reviews.includes(:user)  # Preload users to avoid queries in view
  end 

  def create

  end

  def new

  end

  def destroy

  end
  
end
