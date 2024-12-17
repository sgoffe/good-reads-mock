require 'open-uri'
require 'json'
require 'date'

# Function to fetch book data from Google Books API and seed the books table
def seed_books_from_titles(book_titles)
  book_titles.each do |title|
    # Encode title for the API query
    query = URI.encode_www_form_component(title)
    url = "https://www.googleapis.com/books/v1/volumes?q=intitle:#{query}"

    # Fetch data from Google Books API
    begin
      response = URI.open(url).read
      book_data = JSON.parse(response)

      # Check if any items were returned
      if book_data['items']
        book_info = nil
        # Initializing variables to store final values
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

        # Loop through items and look for missing fields
        book_data['items'].each do |item|
          item_info = item['volumeInfo']

          # If we haven't set title yet, try setting it from this item
          title ||= item_info['title']
          author ||= item_info['authors']&.join(", ") || "Unknown"
          description ||= item_info['description'] || "No description available"
          genre ||= item_info['categories']&.join(", ") || nil
          publisher ||= item_info['publisher'] || "Unknown"

          # Attempt to parse publish_date, if it's not already set
          if publish_date.nil? && item_info['publishedDate']
            begin
              publish_date = Date.parse(item_info['publishedDate'])
            rescue ArgumentError
              puts "Error parsing publish date for '#{title}': #{item_info['publishedDate']}"
              publish_date = nil
            end
          end

          # Set other fields if not already set
          pages ||= item_info['pageCount'] || 0
          language ||= item_info['language'] || "Unknown"
          img_url ||= item_info['imageLinks']&.dig('thumbnail') || "No image available"
          isbn_13 ||= item_info['industryIdentifiers']&.find { |id| id['type'] == 'ISBN_13' }&.dig('identifier')
          google_books_id ||= item['id']  # Ensure we are getting the ID from the correct location
          rating ||= item_info['averageRating'] || "No rating available"
        end

        # Collect missing fields dynamically
        missing_fields = []
        missing_fields << 'title' unless title
        missing_fields << 'publisher' unless publisher
        missing_fields << 'google_books_id' unless google_books_id
        missing_fields << 'publish_date' unless publish_date
        missing_fields << 'isbn_13' unless isbn_13

        # Report if any required fields are missing
        if missing_fields.any?
          puts "Required fields missing for book '#{title}': #{missing_fields.join(', ')}. Skipping..."
        else
          # Ensure we have valid values for required fields before creating the book
          Book.create!(
            title: title,
            author: author,
            description: description,
            publisher: publisher,
            publish_date: publish_date,
            pages: pages,
            language_written: language,
            img_url: img_url,
            isbn_13: isbn_13,
            google_books_id: google_books_id,  # Ensure google_books_id is passed correctly
            genre: genre,
            rating: rating
          )

          puts "Seeded book: #{title}"
        end
      else
        puts "No data found for book: #{title}"
      end
    rescue StandardError => e
      puts "Error fetching data for #{title}: #{e.message}"
    end
  end
end

book_titles = [
  "Ulysses by James Joyce",
  "The Great Gatsby by F. Scott Fitzgerald",
  "One Hundred Years of Solitude by Gabriel García Márquez",
  "Moby-Dick by Herman Melville",
  "War and Peace by Leo Tolstoy",
  "Pride and Prejudice by Jane Austen",
  "The Catcher in the Rye by J.D. Salinger",
  "1984 by George Orwell",
  "The Lord of the Rings by J.R.R. Tolkien",
  "The Odyssey by Homer",
  "Crime and Punishment by Fyodor Dostoevsky",
  "The Brothers Karamazov by Fyodor Dostoevsky",
  "Don Quixote by Miguel de Cervantes",
  "The Divine Comedy by Dante Alighieri",
  "The Iliad by Homer",
  "The Catcher in the Rye by J.D. Salinger",
  "The Bible by various authors",
  "The Canterbury Tales by Geoffrey Chaucer",
  "The Adventures of Huckleberry Finn by Mark Twain",
  "The Grapes of Wrath by John Steinbeck",
  "Brave New World by Aldous Huxley",
  "The Stranger by Albert Camus",
  "The Trial by Franz Kafka",
  "Lolita by Vladimir Nabokov",
  "Middlemarch by George Eliot",
  "The Sound and the Fury by William Faulkner",
  "The Picture of Dorian Gray by Oscar Wilde",
  "The Old Man and the Sea by Ernest Hemingway",
  "The Sun Also Rises by Ernest Hemingway",
  "The Road by Cormac McCarthy",
  "Beloved by Toni Morrison",
  "The Hobbit by J.R.R. Tolkien",
  "The Night Circus by Erin Morgenstern",
  "The Goldfinch by Donna Tartt",
  "The Nightingale by Kristin Hannah",
  "The Tattooist of Auschwitz by Heather Morris",
  "The Book Thief by Markus Zusak",
  "The Help by Kathryn Stockett",
  "The Giver of Stars by Jojo Moyes",
  "The Alice Network by Kate Quinn",
  "The Orphan's Tale by Pam Jenoff",
  "The Paris Library by Janet Skeslien Charles",
  "The Night Watchman by Louise Erdrich",
  "The Underground Railroad by Colson Whitehead",
  "The Nickel Boys by Colson Whitehead",
  "The Silent Patient by Alex Michaelides",
  "The Midnight Library by Matt Haig",
  "The Vanishing Half by Brit Bennett",
  "The Invisible Life of Addie LaRue by V.E. Schwab",
  "The Song of Achilles by Madeline Miller",
  "The Brothers Karamazov by Fyodor Dostoevsky",
  "The Heart of the Matter by Graham Greene",
  "A Tale of Two Cities by Charles Dickens",
  "The Secret History by Donna Tartt",
  "The Outsiders by S.E. Hinton",
  "A Wrinkle in Time by Madeleine L'Engle",
  "The Shining by Stephen King",
  "Dune by Frank Herbert",
  "Fahrenheit 451 by Ray Bradbury",
  "Ender's Game by Orson Scott Card",
  "The Hunger Games by Suzanne Collins",
  "The Girl on the Train by Paula Hawkins",
  "Gone Girl by Gillian Flynn",
  "The Catcher in the Rye by J.D. Salinger",
  "The Fault in Our Stars by John Green",
  "The Kite Runner by Khaled Hosseini",
  "The Time Traveler's Wife by Audrey Niffenegger",
  "The Help by Kathryn Stockett",
  "The Secret Garden by Frances Hodgson Burnett",
  "The Outsiders by S.E. Hinton",
  "The Hound of the Baskervilles by Arthur Conan Doyle",
  "Dracula by Bram Stoker",
  "Frankenstein by Mary Shelley",
  "The Picture of Dorian Gray by Oscar Wilde",
  "The Wizard of Oz by L. Frank Baum",
  "The Chronicles of Narnia by C.S. Lewis",
  "Harry Potter and the Sorcerer's Stone by J.K. Rowling",
  "The Lion, the Witch and the Wardrobe by C.S. Lewis",
  "A Game of Thrones by George R.R. Martin",
  "The Fellowship of the Ring by J.R.R. Tolkien",
  "The Two Towers by J.R.R. Tolkien",
  "The Return of the King by J.R.R. Tolkien",
  "The Hobbit by J.R.R. Tolkien",
  "The Maze Runner by James Dashner",
  "The Hunger Games by Suzanne Collins",
  "Divergent by Veronica Roth",
  "The Giver by Lois Lowry",
  "The Fault in Our Stars by John Green",
  "The Night Circus by Erin Morgenstern",
  "Ready Player One by Ernest Cline",
  "The Martian by Andy Weir",
  "The Nightingale by Kristin Hannah",
  "Circe by Madeline Miller",
  "The Invisible Man by H.G. Wells",
  "The War of the Worlds by H.G. Wells",
  "The Time Machine by H.G. Wells",
  "The Island of Dr. Moreau by H.G. Wells",
  "Brave New World by Aldous Huxley",
  "The Stranger by Albert Camus",
  "The Trial by Franz Kafka",
  "One Flew Over the Cuckoo's Nest by Ken Kesey",
  "Of Mice and Men by John Steinbeck",
  "The Grapes of Wrath by John Steinbeck",
  "East of Eden by John Steinbeck",
  "The House of the Spirits by Isabel Allende"
]


# Call the function to seed books from the list of titles
seed_books_from_titles(book_titles)

# Additional User Creation (if necessary)
u1 = User.create!(first: 'Sophia', last: 'Goffe', email: 'sgoffee@colslay.edu', bio: 'living loving and laughing', password: 'sgoffe')
u2 = User.create!(first: 'Meghan', last: 'Subak', email: 'msubak@colslay.edu', bio: 'body builder and book lover', password: 'msubak')
u3 = User.create!(first: 'Mickey', last: 'Mouse', email: "mmouse@colslay.edu", bio: 'a sassy little mouse', password: 'mmouse')
