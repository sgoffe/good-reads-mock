# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end

# Seeds file to ensure records exist with the new genre as a string
require 'open-uri'
require 'json'
require 'date'

Book.destroy_all
User.destroy_all
Notification.destroy_all

def fetch_and_store_books_data(book_titles)
  # Fetch the book data from the API once and store it in a file
  books_data = []

  book_titles.each do |title|
    query = URI.encode_www_form_component(title)
    url = "https://www.googleapis.com/books/v1/volumes?q=intitle:#{query}"

    begin
      response = URI.open(url).read
      book_data = JSON.parse(response)

      if book_data['items']
        book_info = nil
        title = nil
        author = nil
        description = nil
        genre = nil
        publisher = nil
        publish_date = nil
        pages = nil
        language = nil
        img_url = nil
        isbn_13 = nil
        google_books_id = nil
        rating = nil

        book_data['items'].each do |item|
          item_info = item['volumeInfo']

          title ||= item_info['title']
          author ||= item_info['authors']&.join(", ") || "Unknown"
          description ||= item_info['description'] || "No description available"
          genre ||= item_info['categories']&.join(", ") || nil
          publisher ||= item_info['publisher'] || "Unknown"

          if publish_date.nil? && item_info['publishedDate']
            begin
              publish_date = Date.parse(item_info['publishedDate'])
            rescue ArgumentError
              puts "Error parsing publish date for '#{title}': #{item_info['publishedDate']}"
              publish_date = nil
            end
          end

          pages ||= item_info['pageCount'] || 0
          language ||= item_info['language'] || "Unknown"
          img_url ||= item_info['imageLinks']&.dig('thumbnail') || "default_cover.jpg"
          isbn_13 ||= item_info['industryIdentifiers']&.find { |id| id['type'] == 'ISBN_13' }&.dig('identifier')
          google_books_id ||= item['id']  
          rating ||= item_info['averageRating'] || "No rating available"
        end

        missing_fields = []
        missing_fields << 'title' unless title
        missing_fields << 'publisher' unless publisher
        missing_fields << 'google_books_id' unless google_books_id
        missing_fields << 'publish_date' unless publish_date
        missing_fields << 'isbn_13' unless isbn_13

        if missing_fields.any?
          puts "Required fields missing for book '#{title}': #{missing_fields.join(', ')}. Skipping..."
        else
          books_data << {
            title: title,
            author: author,
            description: description,
            publisher: publisher,
            publish_date: publish_date,
            pages: pages,
            language_written: language,
            img_url: img_url,
            isbn_13: isbn_13,
            google_books_id: google_books_id, 
            genre: genre,
            rating: rating
          }

          puts "Fetched book data: #{title}"
        end
      else
        puts "No data found for book: #{title}"
      end
    rescue StandardError => e
      puts "Error fetching data for #{title}: #{e.message}"
    end
  end

  # Save the data to a file so it can be used later
  File.open("books_data.json", "w") do |file|
    file.write(books_data.to_json)
  end
end

def seed_books_from_file
  # Load the data from the file
  file_data = File.read("books_data.json")
  books = JSON.parse(file_data)

  books.each do |book|
    # Create books from the saved data
    Book.create!(
      title: book["title"],
      author: book["author"],
      description: book["description"],
      publisher: book["publisher"],
      publish_date: book["publish_date"],
      pages: book["pages"],
      language_written: book["language_written"],
      img_url: book["img_url"],
      isbn_13: book["isbn_13"],
      google_books_id: book["google_books_id"],
      genre: book["genre"],
      rating: book["rating"]
    )

    puts "Seeded book: #{book["title"]}"
  end
end

b1 = Book.create!(title: 'Sula',
                author: 'Toni Morrison',
                genre: 'historical_fiction',
                pages: 174,
                description: 'Sula and Nel are two young black girls: clever and poor. They grow up together sharing their secrets, dreams and happiness. Then Sula breaks free from their small-town community in the uplands of Ohio to roam the cities of America. When she returns ten years later much has changed. Including Nel, who now has a husband and three children. The friendship between the two women becomes strained and the whole town grows wary as Sula continues in her wayward, vagabond and uncompromising ways.',
                publisher: 'Plume',
                publish_date: Date.new(1973, 1, 1),
                img_url: nil,
                isbn_13: 9780452283862,
                language_written: 'English',
                google_books_id: '1234567890')

b2 = Book.create!(title: 'Jailbird',
                author: 'Kurt Vonnegut Jr.',
                genre: 'fiction',
                pages: 288,
                description: 'Jailbird takes us into a fractured and comic, pure Vonnegut world of high crimes and misdemeanors in government—and in the heart. This wry tale follows bumbling bureaucrat Walter F. Starbuck from Harvard to the Nixon White House to the penitentiary as Watergate’s least known co-conspirator. But the humor turns dark when Vonnegut shines his spotlight on the cold hearts and calculated greed of the mighty, giving a razor-sharp edge to an unforgettable portrait of power and politics in our times.',
                publisher: 'Dell',
                publish_date: Date.new(1979, 1, 1),
                img_url: nil,
                isbn_13: 9780440154471,
                language_written: 'English',
                google_books_id: '0987654321')

b3 = Book.create!(title: 'Angela\'s Ashes',
                author: 'Frank McCourt',
                genre: 'nonfiction',
                pages: 452,
                description: 'So begins the Pulitzer Prize winning memoir of Frank McCourt, born in Depression-era Brooklyn to recent Irish immigrants and raised in the slums of Limerick, Ireland. Frank\'s mother, Angela, has no money to feed the children since Frank\'s father, Malachy, rarely works, and when he does he drinks his wages. Yet Malachy—exasperating, irresponsible and beguiling—does nurture in Frank an appetite for the one thing he can provide: a story. Frank lives for his father\'s tales of Cuchulain, who saved Ireland, and of the Angel on the Seventh Step, who brings his mother babies.',
                publisher: 'Harper Perennial',
                publish_date: Date.new(1996, 9, 5),
                img_url: nil,
                isbn_13: 9780007205233,
                language_written: 'English',
                google_books_id: '1122334455')

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

r1 = b1.reviews.create!(rating: 5,
                review_text: 'currently my favorite book', 
                user: u1) 

r2 = b2.reviews.create!(rating: 4,
                review_text: 'Maps Fantasy Library', 
                user: u2)

r3 = b3.reviews.create!(rating: 3,
                review_text: 'sad',
                user: u3) 