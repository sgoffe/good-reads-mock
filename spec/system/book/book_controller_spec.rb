require 'rails_helper'
require 'simplecov'
SimpleCov.start 'rails'

RSpec.describe "Book actions", type: :system do
  before do
    driven_by(:rack_test)
  end

  describe "show" do 
    before(:each) do
      @u1 = User.create!(first: "Allie", last: "Amberson", 
                email: "aa@gmail.com", bio:"wassup", 
                password:"aamerson", role: :admin)
                
      @b1 = FactoryBot.create(:book, img_url: nil)
      @b2 = FactoryBot.create(:book, img_url: "https://th.bing.com/th/id/OIP.caKIPkEzOmvoKgGoa-KXwgAAAA?w=135&h=206&c=7&r=0&o=5&dpr=2&pid=1.7")
      @b3 = FactoryBot.create(:book, img_url: nil)

      @r1 = Review.create!(user: @u1, book: @b1, review_text: 'first', rating: 3)
    end

    it 'should have the default image on the show page if there is no image' do
      visit book_path(@b1)
      expect page.has_css?("img[src*='default_book.png']")
    end
  end

  describe 'index' do
    it 'should show genre and rating fields when source is seeded books' do
      visit books_path
      select 'Seeded Books', from: 'Source'
      click_button 'Filter Books'
      expect(page.text).to match(/genre/i)
      expect(page.text).to match(/rating above/i)
    end

    it 'should not show genre and rating fields when source is google books' do
      stub_request(:get, "https://www.googleapis.com/books/v1/volumes?maxResults=10&q=default&startIndex=0")
        .with(
          headers: {
            'Accept'=>'*/*',
            'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
            'User-Agent'=>'Ruby'
          }
        ).to_return(
          status: 200,
          body: { items: [] }.to_json, # Returning a valid JSON with `items` as an empty array
          headers: { 'Content-Type' => 'application/json' }
        )

      visit books_path
      select 'Google Books', from: 'Source'
      click_button 'Filter Books'
      expect(page.text).not_to match(/genre/i)
      expect(page.text).not_to match(/rating above/i)
    end
  end
end

RSpec.describe BooksController, type: :controller do
  describe '#fetch_books_from_google_books' do
    let(:query) { 'test' }
    let(:max_results) { 5 }
    let(:page) { 1 }
    let(:filters) { { genre: 'fiction', author: 'J.K. Rowling', title: 'Harry Potter' } }

    before do
      stub_request(:get, "https://www.googleapis.com/books/v1/volumes?q=#{query}+subject:fiction+inauthor:J.K.+Rowling+intitle:Harry+Potter&startIndex=0&maxResults=#{max_results}")
        .to_return(
          status: 200,
          body: {
            'items' => [{
              'id' => '1',
              'volumeInfo' => {
                'title' => 'Harry Potter and the Sorcerer\'s Stone',
                'authors' => ['J.K. Rowling'],
                'description' => 'A great fantasy novel.',
                'categories' => ['Fiction'],
                'publisher' => 'Bloomsbury',
                'publishedDate' => '1997-06-26',
                'pageCount' => 309,
                'language' => 'en',
                'industryIdentifiers' => [{'type' => 'ISBN_13', 'identifier' => '9780747532743'}],
                'imageLinks' => {'thumbnail' => 'http://example.com/thumbnail.jpg'}
              }
            }],
            'totalItems' => 100
          }.to_json,
          headers: { 'Content-Type' => 'application/json' }
        )
    end

    it 'fetches books from the Google Books API' do
      controller = BooksController.new

      books, has_more_pages = controller.send(:fetch_books_from_google_books, query, max_results, page, filters)

      expect(books).to be_an(Array)
      expect(books.length).to eq(1)
      expect(books.first.title).to eq('Harry Potter and the Sorcerer\'s Stone')
      expect(books.first.author).to eq('J.K. Rowling')
      expect(books.first.isbn_13).to eq('9780747532743')
      expect(has_more_pages).to be_truthy
    end
  end
end
