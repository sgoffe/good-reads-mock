require 'httparty'
require 'ostruct'

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
    volume_info = item['volumeInfo']

    # Try to fetch ISBN-13 (if available)
    isbn_13 = volume_info['industryIdentifiers']&.find { |id| id['type'] == 'ISBN_13' }&.dig('identifier')

    # Create OpenStruct to hold book data
    OpenStruct.new(
      google_books_id: item['id'],
      title: volume_info['title'],
      author: volume_info['authors']&.join(', ') || 'Unknown Author',
      description: volume_info['description'] || 'No description available.',
      genre: volume_info['categories']&.join(', ') || 'Unknown',
      publisher: volume_info['publisher'] || 'Unknown',
      publish_date: volume_info['publishedDate'] || 'Unknown',
      pages: volume_info['pageCount'] || 'Unknown',
      language_written: volume_info['language'] || 'Unknown',
      img_url: volume_info['imageLinks']&.dig('thumbnail') || nil,
      isbn_13: isbn_13  # Retrieve ISBN-13
    )
  end

  [books, has_more_pages]
end

def seed_books
  books = []
  page = 1
  while books.size < 50
    fetched_books, has_more = fetch_books_from_google_books('default', 10, page)
    books.concat(fetched_books)
    break unless has_more || books.size >= 50
    page += 1
  end

  books = books.take(50)

  books.each do |google_book|
    # Skip books with missing ISBN-13, invalid ISBN-13, or missing publish date
    if google_book.isbn_13.blank? || google_book.isbn_13.length != 13 || google_book.publish_date.blank?
      puts "Skipping book: #{google_book.title} due to missing ISBN-13 or publish date"
      next
    end

    # Debugging line for ISBN-13
    puts "ISBN-13 for #{google_book.title}: #{google_book.isbn_13}"

    # Check if book already exists in DB by google_books_id or title and author
    existing_book = Book.find_by(google_books_id: google_book.google_books_id) || Book.find_by(title: google_book.title, author: google_book.author)

    unless existing_book
      # Create new book record with proper validation checks
      begin
        Book.create!(
          google_books_id: google_book.google_books_id,
          title: google_book.title,
          author: google_book.author,
          genre: google_book.genre,
          description: google_book.description,
          publisher: google_book.publisher,
          publish_date: google_book.publish_date.present? ? google_book.publish_date : 'Unknown',
          pages: google_book.pages,
          language_written: google_book.language_written,
          img_url: google_book.img_url,
          isbn_13: google_book.isbn_13
        )
      rescue ActiveRecord::RecordInvalid => e
        puts "Skipping book: #{google_book.title} due to validation error: #{e.message}"
      end
    end
  end
end



# Run the seed function
seed_books


# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end


u1 = User.create!(first: 'Sophia',
last: 'Goffe',
email: 'sgoffee@colslay.edu',
bio: 'living loving and laughing',
password: 'sgoffe')

u2 = User.create!(first: 'Meghan',
last: 'Subak',
email: 'msubak@colslay.edu',
bio: 'body builder and book lover',
password: 'msubak')

u3 = User.create!(first: 'Mickey',
last: 'Mouse',
email: "mmouse@colslay.edu",
bio: 'a sassy little mouse',
password: 'mmouse')

# r1 = b1.reviews.create!(rating: 5,
# review_text: 'currently my favorite book', 
# user: u1) 

# r2 = b2.reviews.create!(rating: 4,
# review_text: 'Maps Fantasy Library', 
# user: u2)

# r3 = b3.reviews.create!(rating: 3,
# review_text: 'sad',
# user: u3) 
