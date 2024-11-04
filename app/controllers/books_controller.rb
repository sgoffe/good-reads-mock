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
  
  def create
    @book = Book.new(create_params)
    if @book.save
      flash[:notice] = "Book #{@book.title} created successfully"
      redirect_to books_path
    else
      flash[:alert] = "Book could not be created" 
      render :new, status: :unprocessable_entity
    end
  end

  def new
    @book = Book.new
  end

  def destroy
    @book = Book.find(params[:id])
    # @book.images.each {|img| img.purge}
    @book.destroy
    redirect_to books_path, notice: 'Book deleted successfully'
  end
    
  private
  
  def create_params
    params.require(:book).permit(:title, :author, :genre, :pages, :description, :publisher, :publish_date, :isbn_13, :language_written) # any other fields
  end
end
