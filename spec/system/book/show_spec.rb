require 'rails_helper'
require 'webmock/rspec'

example_image_url = "https://th.bing.com/th/id/OIP.caKIPkEzOmvoKgGoa-KXwgAAAA?w=135&h=206&c=7&r=0&o=5&dpr=2&pid=1.7"

describe "Book Show Page", type: :feature do
  before(:each) do
    @user = User.create!(
      first: "Allie", 
      last: "Amberson", 
      email: "aa@gmail.com", 
      bio: "wassup", 
      password: "aamerson", 
      role: :admin
    )
    @books = []
    for i in 1..2
      @books << FactoryBot.create(:book, img_url: example_image_url)
    end
    
    @book1 = @books[0]
    @book2 = @books[1]

    @review1 = Review.create!(
      user: @user,
      book: @book1,
      review_text: "Great book!",
      rating: 5
    )

    @review2 = Review.create!(
      user: @user,
      book: @book1,
      review_text: "Not bad.",
      rating: 3
    )

    visit new_user_session_path
    fill_in 'Email', with: @user.email
    fill_in 'Password', with: @user.password
    click_button 'Log in'
  end

  it "displays the book details" do
    for book in @books
      visit book_path(book)

      expect(page).to have_content(book.title)
      expect(page).to have_content(book.author)
      expect(page).to have_content(book.genre)
      expect(page).to have_content(book.pages)
      expect(page).to have_content(book.description)
      expect(page).to have_content(book.publisher)
      expect(page).to have_content(book.publish_date)
      expect(page).to have_content(book.isbn_13)
      expect(page).to have_content(book.language_written)

      expect(page).to have_css("img[src='#{book.img_url}']")
    end
  end

  it "displays reviews and average rating" do
    @books.each do |book|
      visit book_path(book)
  
      # if book.reviews.empty?
      #   expect(page).to have_content("No reviews yet")
      # end
  
      # Iterate through each review and check the content
      book.reviews.each do |review|
        expect(page).to have_content(review.user.first)
        expect(page).to have_content(review.user.last)
        expect(page).to have_content("#{review.rating} stars")
        expect(page).to have_content(review.review_text)
      end
    end
  end
  

  it "has functional links for actions" do
    for book in @books
      visit book_path(book)
      expect(page).to have_link("Find in Library System", href: "https://www.worldcat.org/search?q=isbn:#{book.isbn_13}")
      expect(page).to have_link("Back to index", href: books_path)
      expect(page).to have_link("Write a review", href: new_book_review_path(book))
      expect(page).to have_link("Recommend this book", href: recommend_book_path(book))
    end
  end
  
  it "allows navigation to individual reviews" do
    for book in @books
      visit book_path(book)

      book.reviews.each do |review|
        expect(page).to have_link("More", href: review_path(review))
      end
    end
  end

  it "verifies all buttons work correctly" do
    for book in @books
      visit book_path(book)

      find_link("Find in Library System", href: "https://www.worldcat.org/search?q=isbn:#{book.isbn_13}").click
      expect(page.current_url).to include("worldcat.org")
      visit book_path(book)

      click_link("Back to index")
      expect(current_path).to eq(books_path)
      visit book_path(book)

      click_link("Write a review")
      expect(current_path).to eq(new_book_review_path(book))
      visit book_path(book)

      click_link("Recommend this book")
      expect(current_path).to eq(recommend_book_path(book))
    end
  end

  it "Should redirect to index if book not found" do
    visit book_path(0)
    expect(page.current_path).to eq(books_path)
    expect(page).to have_content("Book not found")
  end
end
