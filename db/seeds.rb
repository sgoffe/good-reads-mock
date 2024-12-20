require 'open-uri'
require 'json'
require 'date'

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


#delete all seeds
Notification.find_each(&:destroy!)
Book.find_each(&:destroy!)
Review.find_each(&:destroy!)
User.find_each(&:destroy!)

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

book_titles = [
  "Ulysses by James Joyce",
  "The Great Gatsby by F. Scott Fitzgerald",
  "One Hundred Years of Solitude by Gabriel García Márquez",
  "Moby-Dick by Herman Melville",
  "War and Peace by Leo Tolstoy",
  "Pride and Prejudice by Jane Austen",
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
  "The Fault in Our Stars by John Green",
  "The Kite Runner by Khaled Hosseini",
  "The Time Traveler's Wife by Audrey Niffenegger",
  "The Secret Garden by Frances Hodgson Burnett",
  "The Hound of the Baskervilles by Arthur Conan Doyle",
  "Dracula by Bram Stoker",
  "Frankenstein by Mary Shelley",
  "The Wizard of Oz by L. Frank Baum",
  "The Chronicles of Narnia by C.S. Lewis",
  "Harry Potter and the Sorcerer's Stone by J.K. Rowling",
  "The Lion, the Witch and the Wardrobe by C.S. Lewis",
  "A Game of Thrones by George R.R. Martin",
  "The Fellowship of the Ring by J.R.R. Tolkien",
  "The Two Towers by J.R.R. Tolkien",
  "The Return of the King by J.R.R. Tolkien",
  "The Maze Runner by James Dashner",
  "Divergent by Veronica Roth",
  "The Giver by Lois Lowry",
  "Ready Player One by Ernest Cline",
  "The Martian by Andy Weir",
  "Circe by Madeline Miller",
  "The Invisible Man by H.G. Wells",
  "The War of the Worlds by H.G. Wells",
  "The Time Machine by H.G. Wells",
  "The Island of Dr. Moreau by H.G. Wells",
  "One Flew Over the Cuckoo's Nest by Ken Kesey",
  "Of Mice and Men by John Steinbeck",
  "East of Eden by John Steinbeck",
  "The House of the Spirits by Isabel Allende"
]

# fetch_and_store_books_data(book_titles)

# Create an admin user
admin = User.create(
  first: 'Admin', 
  last: 'User', 
  email: 'admin@example.com', 
  password: 'adminpassword123', 
  role: 1 # Admin role
)

# Create other users
users = User.create([
  { first: 'John', last: 'Doe', email: 'john.doe@example.com', password: 'password123', role: 0 },
  { first: 'Jane', last: 'Smith', email: 'jane.smith@example.com', password: 'password123', role: 0 },
  { first: 'Alice', last: 'Johnson', email: 'alice.johnson@example.com', password: 'password123', role: 0 },
  { first: 'Bob', last: 'Brown', email: 'bob.brown@example.com', password: 'password123', role: 0 },
  { first: 'Charlie', last: 'Davis', email: 'charlie.davis@example.com', password: 'password123', role: 0 }
])

# Add the admin user to the users array for easier access
users.push(admin)

# Seed books from JSON file
books_data = JSON.parse(File.read('db/books_data.json')) # Assume your books are stored in db/seed_books.json
books = books_data.map do |book_data|
  Book.create(
    google_books_id: book_data['google_books_id'],
    title: book_data['title'],
    author: book_data['author'],
    img_url: book_data['img_url'],
    genre: book_data['genre'],
    publish_date: book_data['publish_date'],
    description: book_data['description'],
    publisher: book_data['publisher'],
    pages: book_data['pages'],
    language_written: book_data['language_written'],
    isbn_13: book_data['isbn_13'],
    rating: book_data['rating']
  )
end

# Create reviews for each book with varied texts
review_texts = [
  "This book is absolutely amazing! I couldn't put it down. Highly recommend it!",
  "I found the storyline captivating, but the pacing was a bit slow in parts.",
  "A great read overall, but some parts felt a little predictable.",
  "The characters were well-developed, but the plot didn't quite live up to expectations.",
  "I couldn't connect with the characters, but the writing was still beautiful.",
  "An interesting story, but it left me wanting more in the end.",
  "A fantastic book! The author did a great job with the world-building.",
  "Not my favorite book, but it was still enjoyable for fans of this genre."
]

books.each do |book|
  3.times do
    user = users.sample
    Review.create(
      rating: rand(1..5),
      review_text: review_texts.sample,
      user: user,
      book: book
    )
  end
end

# Create friendships (randomly link users)
users.each do |user|
  friends = users.reject { |u| u == user } 
  2.times do
    friend = friends.sample
    Friendship.create(user_id: user.id, friend_id: friend.id)
  end
end

# Send notifications (recommending books to friends)
books.each do |book|
  users.each do |user|
    friend = users.reject { |u| u == user }.sample 
    Notification.create(
      sender_id: user.id,
      receiver_id: friend.id,
      title: "Book Recommendation",
      message: "#{user.first} recommends the book '#{book.title}' to you.",
      notifiable_type: 'Book',
      notifiable_id: book.id
    )
  end
end

puts "Seeding completed!"

