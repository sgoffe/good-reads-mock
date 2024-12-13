require 'rails_helper'
require 'webmock/rspec'

example_image_url = "https://th.bing.com/th/id/OIP.caKIPkEzOmvoKgGoa-KXwgAAAA?w=135&h=206&c=7&r=0&o=5&dpr=2&pid=1.7"

RSpec.shared_context "Google Books API Setup" do
  let(:google_api_response) do
    {
      "volumeInfo" => {
        "title" => "Google Book Title",
        "authors" => ["Google Author"],
        "description" => "Google Book Description",
        "categories" => ["Fiction"],
        "publisher" => "Google Publisher",
        "publishedDate" => "2022-01-01",
        "pageCount" => 300,
        "language" => "English",
        "id" => "google_1",
        "industryIdentifiers" => [{"type" => "ISBN_13", "identifier" => "1234567890123"}],
        "imageLinks" => {"thumbnail" => example_image_url}
      }
    }.to_json
  end

  before do
    WebMock.disable_net_connect!(allow_localhost: true)
    stub_request(:get, "https://www.googleapis.com/books/v1/volumes/google_1")
      .to_return(status: 200, body: google_api_response, headers: { 'Content-Type' => 'application/json' })
  end
end 

RSpec.describe "Book Index with Google Books", type: :feature do
  include_context "Google Books API Setup"

  before do
    @user = User.create!(first: "John", last: "Doe", email: "john@example.com", password: "password", role: :admin)

    @books = [
      { title: "a_test1", isbn_13: 1111111111111 },
      { title: "a_test2", isbn_13: 2222222222222 },
      { title: "a_test3", isbn_13: 3333333333333 }
    ].map do |attrs|
      Book.create!(
        title: attrs[:title],
        author: "test",
        description: "test",
        genre: "nonfiction",
        publisher: "test",
        publish_date: Date.new(2222, 2, 2),
        language_written: "test",
        pages: 100,
        isbn_13: attrs[:isbn_13],
        img_url: example_image_url
      )
    end

    allow_any_instance_of(BooksController).to receive(:fetch_books_from_google_books).and_return([
      [
        OpenStruct.new(
          id: "1",
          title: "Google Book 1",
          author: "Google Author 1",
          description: "Description 1",
          genre: "Genre 1",
          publisher: "Publisher 1",
          publish_date: "2023",
          pages: 123,
          language_written: "en",
          isbn_13: "1234567890123",
          img_url: example_image_url
        ),
        OpenStruct.new(
          id: "2",
          title: "Google Book 2",
          author: "Google Author 2",
          description: "Description 2",
          genre: "Genre 2",
          publisher: "Publisher 2",
          publish_date: "2024",
          pages: 456,
          language_written: "en",
          isbn_13: "9876543210987",
          img_url: example_image_url
        )
      ],
      false
    ])
  end

  it "displays books from Google Books API when the filter is applied" do
    visit books_path

    select "Google Books", from: "source"
    click_button "Filter Books"

    expect(page).to have_content("Google Book 1")
    expect(page).to have_content("Google Author 1")
    expect(page).to have_content("Google Book 2")
    expect(page).to have_content("Google Author 2")

    expect(page).to have_xpath("//img[@src='#{example_image_url}']")

    @books.each do |book|
      expect(page).not_to have_content(book.title)
    end
  end
end

RSpec.describe "Google Books Integration", type: :system do
  include_context "Google Books API Setup"

  before do
    @user = User.create!(first: "John", last: "Doe", email: "john@example.com", password: "password", role: :admin)
  end

  it "shows Google book details" do
    visit google_book_path(id: 'google_1', query: 'Testing')

    expect(page).to have_content('Google Book Title')
    expect(page).to have_content('Google Author')
    expect(page).to have_content('Google Book Description')
    expect(page).to have_content('Fiction')
    expect(page).to have_content('Google Publisher')
    expect(page).to have_content('2022-01-01')
    expect(page).to have_content('300')
    expect(page).to have_content('English')
    expect(page).to have_content('1234567890123')
    expect(page).to have_xpath("//img[@src='#{example_image_url}']")
  end

  it "handles exceptions correctly when fetching Google books" do
    allow(HTTParty).to receive(:get).and_raise(StandardError)
    visit google_book_path(id: 'google_1', query: 'Testing')
    expect(page).to have_content('Something went wrong while fetching Google Books data')
  end
end

RSpec.describe "Existing Google Books", type: :system do
  include_context "Google Books API Setup"

  before do
    @user = User.create!(first: "John", last: "Doe", email: "john@example.com", password: "password", role: :admin)

    @existing_book = Book.create!(
      title: "Google Book Title",
      author: "Google Author",
      genre: "Fiction",
      pages: 100,
      description: "Existing Book Description",
      publisher: "Existing Publisher",
      publish_date: Date.new(2222, 2, 2),
      isbn_13: 1234567890123,
      language_written: "English",
      img_url: example_image_url
    )
  end

  it "displays existing book details correctly" do
    visit google_book_path(id: 'google_1', query: 'Testing')

    expect(page).to have_current_path(book_path(@existing_book))
    expect(page).to have_content(@existing_book.title)
    expect(page).to have_content(@existing_book.author)
    expect(page).to have_content(@existing_book.description)
    expect(page).to have_content(@existing_book.genre)
    expect(page).to have_content(@existing_book.publisher)
    expect(page).to have_content(@existing_book.publish_date)
    expect(page).to have_content(@existing_book.pages)
    expect(page).to have_content(@existing_book.language_written)
    expect(page).to have_content(@existing_book.isbn_13)
    expect(page).to have_xpath("//img[@src='#{@existing_book.img_url}']")
  end

  it "shows an error if Google book is not found" do
    stub_request(:get, "https://www.googleapis.com/books/v1/volumes/invalid_id")
      .to_return(status: 404, body: "", headers: {})

    visit google_book_path(id: 'invalid_id', query: 'Invalid Query')

    expect(page).to have_content('Google book not found')
    expect(page).to have_current_path(books_path)
  end
end