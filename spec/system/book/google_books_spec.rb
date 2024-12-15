require 'rails_helper'
require 'webmock/rspec'

example_image_url = "https://th.bing.com/th/id/OIP.caKIPkEzOmvoKgGoa-KXwgAAAA?w=135&h=206&c=7&r=0&o=5&dpr=2&pid=1.7"

def stub_google_books_search(query, result, filters = {})
  allow_any_instance_of(BooksController).to receive(:fetch_books_from_google_books).with(
    query, 10, 1, hash_including(filters)
  ).and_return([result, false])
end

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
    @google_books = [
      OpenStruct.new(
        id: "1",
        title: "default Classic novel Google Book 1",
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
        title: "default New novel Google Book 2",
        author: "Google Author 2",
        description: "Description 2",
        genre: "Genre 2",
        publisher: "Publisher 2",
        publish_date: "2024",
        pages: 123,
        language_written: "en",
        isbn_13: "1234567890123",
        img_url: example_image_url
      )
    ]
    @gbook1 = @google_books[0]
    @gbook2 = @google_books[1]

    # Default stub for unexpected arguments
  allow_any_instance_of(BooksController).to receive(:fetch_books_from_google_books).with(
    anything, anything, anything, anything
  ).and_return([[], false])

  # Stubbing specific cases using a helper method
  stub_google_books_search("default", [@gbook1, @gbook2], title: "", author: "", genre: "")
  stub_google_books_search("", [@gbook1, @gbook2], title: "", author: "", genre: "")
  stub_google_books_search("google book", [@gbook1], title: "Classic novel", author: "", genre: "")
  stub_google_books_search("google book", [@gbook2], title: "New novel", author: "", genre: "")
  stub_google_books_search("google book", [@gbook1], title: "", author: "Google Author 1", genre: "")
  stub_google_books_search("google book", [@gbook2], title: "", author: "Google Author 2", genre: "")
  stub_google_books_search("google book", [@gbook1], title: "", author: "", genre: "genre 1")
  stub_google_books_search("google book", [@gbook2], title: "", author: "", genre: "genre 2")
  end

  it "displays books from Google Books API when source is selected" do
    visit books_path

    select "Google Books", from: "source"
    click_button "Filter Books"

    expect(page).to have_content(@gbook1.title)
    expect(page).to have_content(@gbook1.author)
    expect(page).to have_xpath("//img[@src='#{@gbook1.img_url}']")
  end

  it "filters Google Books results by title keyword" do
    visit books_path(source: 'google_books', query: 'google book', filter: { title: 'Classic novel' })

    expect(page).to have_content(@gbook1.title)
    expect(page).to have_content(@gbook1.author)
    expect(page).not_to have_content(@gbook2.title)
    expect(page).not_to have_content(@gbook2.author)

    visit books_path(source: 'google_books', query: 'google book', filter: { title: 'New novel' })

    expect(page).to have_content(@gbook2.title)
    expect(page).to have_content(@gbook2.author)
    expect(page).not_to have_content(@gbook1.title)
    expect(page).not_to have_content(@gbook1.author)
  end

  it "filters Google Books results by author" do
    visit books_path(source: 'google_books', query: 'google book', filter: { author: 'Google Author 1' })

    expect(page).to have_content(@gbook1.title)
    expect(page).to have_content(@gbook1.author)
    expect(page).not_to have_content(@gbook2.title)
    expect(page).not_to have_content(@gbook2.author)

    visit books_path(source: 'google_books', query: 'google book', filter: { author: 'Google Author 2' })

    expect(page).to have_content(@gbook2.title)
    expect(page).to have_content(@gbook2.author)
    expect(page).not_to have_content(@gbook1.title)
    expect(page).not_to have_content(@gbook1.author)
  end

  it "filters Google Books results by genre" do
    visit books_path(source: 'google_books', query: 'google book', filter: { genre: 'genre 1' })

    expect(page).to have_content(@gbook1.title)
    expect(page).to have_content(@gbook1.author)
    expect(page).not_to have_content(@gbook2.title)
    expect(page).not_to have_content(@gbook2.author)

    visit books_path(source: 'google_books', query: 'google book', filter: { genre: 'genre 2' })

    expect(page).to have_content(@gbook2.title)
    expect(page).to have_content(@gbook2.author)
    expect(page).not_to have_content(@gbook1.title)
    expect(page).not_to have_content(@gbook1.author)
  end

  it "returns no results if filters do not match any books" do
    visit books_path(source: 'google_books', query: 'google book', filter: { title: 'Nonexistent Book' })

    expect(page).to have_content("No books found")
    expect(page).not_to have_content(@gbook1.title)
    expect(page).not_to have_content(@gbook1.author)
    expect(page).not_to have_content(@gbook2.title)
    expect(page).not_to have_content(@gbook2.author)
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
      publish_date: Date.new(2002, 2, 2),
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

RSpec.describe BooksController, type: :controller do
  describe 'POST #add_google_book' do
    let(:valid_google_book_params) do
      {
        book: {
          title: 'Test Book Title',
          author: 'Test Author',
          genre: 'Fiction',
          description: 'A test book description',
          publisher: 'Test Publisher',
          publish_date: '2024-01-01',
          pages: 300,
          language_written: 'en',
          isbn_13: '9781234567897',
          img_url: example_image_url
        }
      }
    end

    let(:existing_book) do
      Book.create!(
        title: 'Test Book Title',
        author: 'Test Author',
        genre: 'Fiction',
        description: 'A test book description',
        publisher: 'Test Publisher',
        publish_date: '2024-01-01',
        pages: 300,
        language_written: 'en',
        isbn_13: '9781234567897',
        img_url: example_image_url
      )
    end

    context 'when the book does not already exist' do
      it 'creates a new book and redirects to its show page' do
        expect do
          post :add_google_book, params: valid_google_book_params
        end.to change(Book, :count).by(1)

        created_book = Book.last
        expect(created_book.title).to eq(valid_google_book_params[:book][:title])
        expect(created_book.author).to eq(valid_google_book_params[:book][:author])
        expect(created_book.genre).to eq(valid_google_book_params[:book][:genre])
        expect(created_book.isbn_13).to eq(valid_google_book_params[:book][:isbn_13])
        expect(response).to redirect_to(book_path(created_book))
        expect(flash[:notice]).to eq("Google Book 'Test Book Title' was successfully added.")
      end
    end

    context 'when the book already exists by ISBN' do
      before { existing_book }

      it 'redirects to the existing book show page with a notice' do
        expect do
          post :add_google_book, params: valid_google_book_params
        end.not_to change(Book, :count)

        expect(response).to redirect_to(book_path(existing_book))
        expect(flash[:notice]).to eq("This book is already in your library.")
      end
    end

    context 'when the book already exists by title and author' do
      before { existing_book }

      it 'redirects to the existing book show page with a notice' do
        params_without_isbn = valid_google_book_params.dup
        params_without_isbn[:book].delete(:isbn_13)

        expect do
          post :add_google_book, params: params_without_isbn
        end.not_to change(Book, :count)

        expect(response).to redirect_to(book_path(existing_book))
        expect(flash[:notice]).to eq("This book is already in your library.")
      end
    end

    context 'when the book data is invalid' do
      let(:invalid_google_book_params) do
        { book: { title: '', author: '', isbn_13: '' } }
      end

      it 'does not create a new book and redirects to the books index with an alert' do
        expect do
          post :add_google_book, params: invalid_google_book_params
        end.not_to change(Book, :count)

        expect(response).to redirect_to(books_path)
        expect(flash[:alert]).to eq("Error adding Google Book.")
      end
    end
  end
end