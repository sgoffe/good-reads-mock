require 'ostruct'

class BooksController < ApplicationController

  def index
    if params[:source] == 'google_books'
      @books = fetch_books_from_google_books(params[:query])
    elsif params[:source] == 'seeded_books'
      @books = Book.all.order(:title)
    else
      @books = Book.all.order(:title) # Default case when no source is specified
    end
  
    # Apply search query filtering if query is present
    if params[:query].present? && params[:query].length > 2
      if params[:source] == 'google_books'
        # Manually filter Google Books by title or author using select!
        @books.select! { |book| book.title.downcase.include?(params[:query].downcase) || book.author.to_s.downcase.include?(params[:query].downcase) }
      else
        @books = @books.by_search_string(params[:query])
      end
      @query_filt = params[:query]
    end
  
    # Apply rating filtering if rating is provided
    if params[:rating].present?
      if params[:source] == 'google_books'
        # Manually filter Google Books by rating
        @books.select! { |book| book.respond_to?(:average_rating) && book.average_rating.to_f >= params[:rating].to_f }
      else
        @books = @books.with_average_rating(params[:rating].to_f)
      end
      @rating_filt = params[:rating]
    end
  
    # Apply genre filtering if genre is provided
    if params[:genre].present?
      if params[:source] == 'google_books'
        # Manually filter Google Books by genre
        @books.select! { |book| book.genre.to_s.downcase.include?(params[:genre].downcase) }
      else
        @books = @books.in_genre(params[:genre])
      end
      @genre_filt = params[:genre]
    end
  
    # Apply sorting if sort param is provided
    if params[:sort].present?
      if params[:source] == 'google_books'
        # Manually sort Google Books based on title or rating
        if params[:sort].match(/title/i)
          @books.sort_by! { |book| book.title }
        elsif params[:sort].match(/rating/i)
          @books.sort_by! { |book| -book.average_rating.to_f }
        end
      else
        @books = @books.unscope(:order)
        if(params[:sort].match(/rating/i)) 
          @books = @books.rating
        end
        @books = @books.order(params[:sort])
      end
      @sort_filt = params[:sort]
    end
  
    # Define sorts for the Book model
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

  def show_google
    @book = Book.find_by(id: params[:id])

    unless @book
      redirect_to books_path, alert: "Book not found"
    end
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
    # @book.images.each {|img| img.purge }
    @book.destroy
    redirect_to books_path, notice: 'Book deleted successfully'
  end
    
  private
  
  def create_params
    params.require(:book).permit(:title, :author, :genre, :pages, :description, :publisher, :publish_date, :isbn_13, :language_written) # any other fields
  end

  # google books API response parser helper function
  def fetch_books_from_google_books(query = 'Testing')
    url = "https://www.googleapis.com/books/v1/volumes?q=#{query}"
    response = HTTParty.get(url)
    books_data = response.parsed_response["items"] || []
  
    books_data.map.with_index do |item, index|
      OpenStruct.new(
        id: "google_#{index}",
        title: item["volumeInfo"]["title"],
        author: item["volumeInfo"]["authors"]&.join(', ') || 'Unknown Author',
        description: item["volumeInfo"]["description"] || 'No description available.',
        genre: item["volumeInfo"]["categories"]&.join(', ') || 'Unknown',
        publisher: item["volumeInfo"]["publisher"] || 'Unknown'
      )
    end
  end
end
