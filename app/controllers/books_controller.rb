require 'ostruct'
require 'nokogiri'

class BooksController < ApplicationController
  before_action :set_global_query, only: [:index, :show_google]

  def index
    params[:source] ||= 'seeded_books'
    params[:page] = params[:page].to_i > 0 ? params[:page].to_i : 1
    @per_page = 10
  
    if params[:source] == 'google_books'
      filters = {
        title: params.dig(:filter, :title) || "",
        author: params.dig(:filter, :author) || "",
        genre: params.dig(:filter, :genre) || ""
      }

      @books, @has_more_pages = fetch_books_from_google_books(@query, @per_page, params[:page], filters)
    else
      @books = Book.all.order(:title).page(params[:page]).per(@per_page)
      @has_more_pages = @books.current_page < @books.total_pages
    end  
  
    # Search query filtering
    if params[:query].present? && @query.length > 2
      @query = params[:query]
      if params[:source] == 'google_books'
        @books.select! do |book|
          book[:title].to_s.downcase.include?(params[:query].downcase) || 
          book[:author].to_s.downcase.include?(params[:query].downcase)
        end
      else
        @books = @books.by_search_string(params[:query])
      end
      @query_filt = params[:query]
    end
  
    # Rating filtering
    if params[:rating].present?
      if params[:source] == 'google_books'
        # Skip rating filter for Google Books
      else
        @books = Book.joins(:reviews)
                     .group("books.id")
                     .select("books.*, AVG(reviews.rating) AS avg_rating")
                     .having("AVG(reviews.rating) >= ?", params[:rating].to_f)
                     .order("avg_rating DESC")
      end
      @rating_filt = params[:rating]
    end
  
    # Genre filtering
    if params[:genre].present?
      if params[:source] == 'google_books'
        # genre filter shouldnt matter for the google books
        # @books.select! { |book| book.genre.to_s.downcase.include?(params[:genre].downcase) }
      else
        @books = Book.where(genre: params[:genre])
      end
      @genre_filt = params[:genre]
    end
  
    # Apply sorting if sort param is provided
    if params[:sort].present?
      if params[:source] == 'google_books'
        @books.sort_by! { |book| params[:sort].include?('rating') ? -book.average_rating.to_f : book.title }
      else
        @books = @books.unscope(:order).order(params[:sort])
      end
      @sort_filt = params[:sort]
    end
  
    # Sort options
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
  rescue ActiveRecord::RecordNotFound
    redirect_to books_path, alert: "Book not found."
  end

  def show_google
    google_id = params[:id]
  
    # Fetch book details from Google Books API
    url = "https://www.googleapis.com/books/v1/volumes/#{google_id}"
    response = HTTParty.get(url)
  
    if response.success?
      book_data = response.parsed_response['volumeInfo']
      
      @book = OpenStruct.new(
        id: google_id,
        title: book_data['title'],
        author: book_data['authors']&.join(', ') || 'Unknown Author',
        description: (book_data['description']) || 'No description available.',
        genre: book_data['categories']&.join(', ') || 'Unknown',
        publisher: book_data['publisher'] || 'Unknown',
        publish_date: book_data['publishedDate'] || Date.today.to_s,
        pages: book_data['pageCount'] || 0,
        language_written: book_data['language'] || 'Unknown',
        isbn_13: book_data['industryIdentifiers']&.find { |id| id['type'] == 'ISBN_13' }&.dig('identifier') || SecureRandom.uuid,
        img_url: book_data['imageLinks']&.dig('thumbnail')
      )
    
      existing_book = Book.find_by(isbn_13: @book.isbn_13) ||
        Book.find_by(title: @book.title, author: @book.author)

      if existing_book
        redirect_to book_path(existing_book)
      else
        new_book = Book.create(
          title: @book.title.presence || "Unknown Title",
          author: @book.author.presence || "Unknown Author",
          description: @book.description.presence || "No description available.",
          genre: @book.genre.presence || "Unknown",
          publisher: @book.publisher.presence || "Unknown",
          publish_date: (@book.publish_date.presence && Date.parse(@book.publish_date) rescue Date.today),
          pages: @book.pages.presence || 0,
          language_written: @book.language_written.presence || "Unknown",
          isbn_13: @book.isbn_13.presence || SecureRandom.uuid,
          google_books_id: google_id,
          img_url: @book.img_url
        )
    
        if new_book.persisted?
          redirect_to book_path(new_book)
        else
          Rails.logger.error("Failed to save Google Book: #{new_book.errors.full_messages}")
          flash[:alert] = "Failed to save book to the database."
          redirect_to books_path
        end
      end
    else
      flash[:alert] = "Google book not found"
      redirect_to books_path
    end
  rescue StandardError => e
    # Handle unexpected errors
    Rails.logger.error("Error fetching Google Books data: #{e.message}")
    flash[:alert] = "Something went wrong while fetching Google Books data"
    redirect_to books_path
  end
  
  def create
    @book = Book.new(create_params)
    @book.google_books_id ||= SecureRandom.uuid
    
    if @book.save
      if params[:book][:image].present?
        @book.image.attach(params[:book][:image])
        if @book.image.attached?
          @book.update(img_url: url_for(@book.image))
        end
      end
  
      flash[:notice] = "Book '#{@book.title}' created successfully."
      redirect_to books_path
    else
      flash[:alert] = "Book could not be created."
      render :new, status: :unprocessable_entity
    end
  end
  
  def new
    @book = Book.new
  end

  def clean_html_description(html)
    doc = Nokogiri::HTML.fragment(html)
    clean_text = doc.css('p').map(&:text).join("\n\n")
    clean_text.gsub(/\u00A0/, ' ')
  end

  def add_google_book
    book_params = params.require(:book).permit(
      :title, :author, :google_books_id ,:genre, :description, :publisher, :publish_date,
      :pages, :language_written, :isbn_13, :img_url
    )
  
    existing_book = Book.find_by(isbn_13: book_params[:isbn_13]) || 
                    Book.find_by(title: book_params[:title], author: book_params[:author])
  
    if existing_book
      redirect_to book_path(existing_book), notice: "This book is already in your library."
      return
    end
  
    @google_book = Book.new(book_params)
    @google_book.description = clean_html_description(book_params[:description]) if book_params[:description].present?
  
    if @google_book.save
      redirect_to book_path(@google_book), notice: "Google Book '#{@google_book.title}' was successfully added."
    else
      flash[:alert] = "Error adding Google Book."
      redirect_to books_path
    end
  end
  

  def destroy
    @book = Book.find(params[:id])
    # @book.images.each {|img| img.purge }
    @book.destroy
    redirect_to books_path, notice: 'Book deleted successfully'
  end
    
  private
  
  def create_params
    params.require(:book).permit(:title, :author, :genre, :pages, :description, :publisher, :publish_date, :isbn_13, :language_written, :img_url)
  end

  def set_global_query
    @query = params[:query] || ''
  end

  # Google Books API response parser helper function
  def fetch_books_from_google_books(query = 'default', max_results = 10, page = 1, filters = {})
    query = 'default' if query.blank?
    start_index = (page - 1) * max_results
    filter_query = ""
  
    # Add filters to the query
    filter_query += "+subject:#{filters[:genre]}" if filters[:genre].present?
    filter_query += "+inauthor:#{filters[:author]}" if filters[:author].present?
    filter_query += "+intitle:#{filters[:title]}" if filters[:title].present?
  
    # Build URL with filters
    url = "https://www.googleapis.com/books/v1/volumes?q=#{query}#{filter_query}&startIndex=#{start_index}&maxResults=#{max_results}"
    
    response = HTTParty.get(url)
  
    books_data = response.parsed_response['items'] || []
    total_items = response.parsed_response['totalItems'] || 0
    has_more_pages = start_index + books_data.size < total_items
  
    books = books_data.map do |item|
      OpenStruct.new(
        google_books_id: item['id'],
        title: item['volumeInfo']['title'],
        author: item['volumeInfo']['authors']&.join(', ') || 'Unknown Author',
        description: clean_html_description(item['volumeInfo']['description']) || 'No description available.',
        genre: item['volumeInfo']['categories']&.join(', ') || 'Unknown',
        publisher: item['volumeInfo']['publisher'] || 'Unknown',
        publish_date: item['volumeInfo']['publishedDate'] || 'Unknown',
        pages: item['volumeInfo']['pageCount'] || 'Unknown',
        language_written: item['volumeInfo']['language'] || 'Unknown',
        isbn_13: item['volumeInfo']['industryIdentifiers']&.find { |id| id['type'] == 'ISBN_13' }&.dig('identifier') || 'Unknown',
        img_url: item['volumeInfo']['imageLinks']&.dig('thumbnail') || nil
      )
    end
  
    [books, has_more_pages]
  end
end