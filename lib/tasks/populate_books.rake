require 'httparty'
require 'open-uri'

namespace :populate do
  desc "Populate the database with books from Google Books API, 5 from each genre"
  task books: :environment do
    base_url = 'https://www.googleapis.com/books/v1/volumes'
    max_results = 5 

    genres = ['fiction', 'non-fiction', 'science', 'history', 'fantasy', 'mystery', 'biography']

    genres.each do |genre|
      start_index = 0
      total_books_fetched = 0

      loop do
        url = "#{base_url}?q=subject:#{genre}&maxResults=#{max_results}&startIndex=#{start_index}"
        response = HTTParty.get(url)

        break if response.parsed_response["items"].nil? || response.parsed_response["items"].empty?

        response.parsed_response["items"].each do |item|
          volume_info = item["volumeInfo"]

          book = Book.new(
            title: volume_info["title"],
            author: volume_info["authors"]&.join(", "),
            # genre: volume_info["categories"]&.first&.downcase&.tr(" ", "_") || "unknown",
            genre: genre,
            pages: volume_info["pageCount"],
            description: volume_info["description"],
            publisher: volume_info["publisher"],
            publish_date: volume_info["publishedDate"],
            isbn_13: volume_info["industryIdentifiers"]&.find { |id| id["type"] == "ISBN_13" }&.dig("identifier"),
            language_written: volume_info["language"]
          )

          # Attach image if available
          if volume_info["imageLinks"] && volume_info["imageLinks"]["thumbnail"]
            image_url = volume_info["imageLinks"]["thumbnail"]
            puts "Downloading image for book '#{book.title}' from URL: #{image_url}"
            book.images.attach(io: URI.open(image_url), filename: "#{book.title}.jpg")
          end

          book.save
          total_books_fetched += 1
        end

        break if total_books_fetched >= max_results

        start_index += max_results
        puts "Fetched #{response.parsed_response["items"].count} books for genre '#{genre}'. Total for this genre: #{total_books_fetched}"
      end

      puts "Total books populated from genre '#{genre}': #{total_books_fetched}"
    end

    puts "Finished populating books from all genres."
  end
end
