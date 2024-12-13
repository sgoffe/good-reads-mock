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

    @book = Book.create!(
      title: "Example Book",
      author: "John Doe",
      genre: "Fiction",
      pages: 250,
      description: "An example description.",
      publisher: "Test Publisher",
      publish_date: Date.new(2023, 1, 1),
      isbn_13: 1234567890123,
      language_written: "English",
      img_url: example_image_url
    )

    @review1 = Review.create!(
      user: @user,
      book: @book,
      review_text: "Great book!",
      rating: 5
    )

    @review2 = Review.create!(
      user: @user,
      book: @book,
      review_text: "Not bad.",
      rating: 3
    )

    visit new_user_session_path
    fill_in 'Email', with: @user.email
    fill_in 'Password', with: @user.password
    click_button 'Log in'
  end

  it "displays the book details" do
    visit book_path(@book)

    expect(page).to have_content(@book.title)
    expect(page).to have_content(@book.author)
    expect(page).to have_content(@book.genre)
    expect(page).to have_content(@book.pages)
    expect(page).to have_content(@book.description)
    expect(page).to have_content(@book.publisher)
    expect(page).to have_content(@book.publish_date)
    expect(page).to have_content(@book.isbn_13)
    expect(page).to have_content(@book.language_written)

    expect(page).to have_css("img[src='#{@book.img_url}']")
  end

  it "displays reviews and average rating" do
    visit book_path(@book)

    expect(page).to have_content("Average rating: 4.0 stars")

    @book.reviews.each do |review|
      expect(page).to have_content(review.user.first)
      expect(page).to have_content(review.user.last)
      expect(page).to have_content("#{review.rating} stars")
      expect(page).to have_content(review.review_text)
    end
  end

  it "has functional links for actions" do
    visit book_path(@book)

    expect(page).to have_link("Find in Library System", href: "https://www.worldcat.org/search?q=isbn:#{@book.isbn_13}")
    expect(page).to have_link("Back to index", href: books_path)
    expect(page).to have_link("Write a review", href: new_book_review_path(@book))
    expect(page).to have_link("Recommend this book", href: recommend_book_path(@book))
  end
  
  # already another test for deleting a book
  # it "allows book deletion with confirmation" do
  #   visit book_path(@book)
  #   accept_confirm do
  #     click_button 'Delete book (will need permissions)'
  #   end

  #   expect(page).to have_content('Book deleted successfully')
  #   expect(page).not_to have_content(@bbook.title)
  # end

  it "allows navigation to individual reviews" do
    visit book_path(@book)

    @book.reviews.each do |review|
      expect(page).to have_link("More", href: review_path(review))
    end
  end

  it "verifies all buttons work correctly" do
    visit book_path(@book)

    find_link("Find in Library System", href: "https://www.worldcat.org/search?q=isbn:#{@book.isbn_13}").click
    expect(page.current_url).to include("worldcat.org")
    visit book_path(@book)

    click_link("Back to index")
    expect(current_path).to eq(books_path)
    visit book_path(@book)

    click_link("Write a review")
    expect(current_path).to eq(new_book_review_path(@book))
    visit book_path(@book)

    click_link("Recommend this book")
    expect(current_path).to eq(recommend_book_path(@book))
  end
end
