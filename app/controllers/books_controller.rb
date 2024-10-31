class BooksController < ApplicationController
  def index
    @books = Book.all.order(:title)
    if params[:query].present?
      @books = @books.by_search_string(params[:query])
    end
  end

  def show
    @book = Book.find(params[:id])
  end

  # def create

  # end

  # def new

  # end

  # def destroy

  # end
end
