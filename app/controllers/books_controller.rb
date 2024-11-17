class BooksController < ApplicationController
  def index
    @books = Book.all.order(:title)

    if params[:query].present? && params[:query].length > 2
      @books = @books.by_search_string(params[:query])
      @query_filt = params[:query]
    end

    if params[:rating].present?
      @books = @books.with_average_rating(params[:rating].to_f)
      @rating_filt = params[:rating]
    end

    if params[:sort].present?
      @books = @books.unscope(:order)
      if(params[:sort].match(/rating/i)) 
        @books = @books.rating
      end
      @books = @books.order(params[:sort])
      @sort_filt = params[:sort]
      Rails.logger.debug(@books.to_sql)
    end

    if params[:genre].present?
      @books = @books.in_genre(params[:genre])
      @genre_filt = params[:genre]
    end

    @sorts = [
      ["Title - A to Z", "title ASC"],
      ["Title - Z to A", "title DESC"],
      ["Rating - Highest to Lowest", "rating DESC"],
      ["Rating - Lowest to Highest", "rating ASC"],
      ["Author - A to Z", "author ASC"],
      ["Author - Z to A", "author DESC"],
      ["Release Date - Newest to Oldest", "publish_date DESC"],
      ["Release Date - Oldest to Newest", "publish_date ASC"]
    ]
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
