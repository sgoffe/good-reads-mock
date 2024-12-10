require 'rails_helper'
require 'simplecov'
SimpleCov.start 'rails'

RSpec.describe "Book actions", type: :system do
  before do
    driven_by(:rack_test)
  end

  describe "create a new book " do
    it 'successful create' do
      visit new_book_path
      fill_in 'Title', with: 'Test Book'
      fill_in 'Author', with: 'Test Description'
      fill_in 'Genre', with: 'Fiction' 
      fill_in 'Pages', with: 100
      fill_in 'Description', with: '0123456789'
      fill_in 'Publisher', with: 'Test Publisher'
      fill_in 'Publish date', with: "2022-02-02"
      fill_in 'Isbn 13', with: 0000000000000
      fill_in 'Language written', with: 'Test language'
      # attach_file 'Images', "#{Rails.root}/spec/testimg.jpg"
      click_on 'Create Book'
      expect(page).to have_content('Book Test Book created successfully')
      expect(page.current_path).to eq(books_path)
      expect(page).to have_content('Test Book')
    end
    
    it 'unsuccessful create' do
      b = Book.new
      allow(Book).to receive(:new).and_return(b)
      allow(b).to receive(:save).and_return(nil)
      visit new_book_path
      click_on 'Create Book'
      expect(page.current_path).to eq(books_path) # assume no redirect, just render 'new'
      expect(page.text).to match(/Book could not be created/)
    end
  end

  describe "show" do 
    before(:each) do
      @u1 = User.create!(first: "Allie", last: "Amberson", 
                email: "aa@gmail.com", bio:"wassup", 
                password:"aamerson", role: :admin)
      @b1 = Book.create!(title: "a_test1", author: "test",
                  genre: "fiction", 
                  pages: 100, description: "test",
                  publisher: "test",
                  publish_date: Date.new(2222, 2, 2), isbn_13: 1111111111111, language_written: "test")
      @b2 = Book.create!(title: "b_test2", author: "test",
                  genre: "fiction", 
                  pages: 200, description: "test",
                  publisher: "test",
                  publish_date: Date.new(2222, 2, 2), isbn_13: 1111111111111, language_written: "test")
      @b3 = Book.create!(title: "c_test3", author: "test",
                  genre: "fiction", 
                  pages: 300, description: "test",
                  publisher: "test",
                  publish_date: Date.new(2222, 2, 2), isbn_13: 1111111111111, language_written: "test")
      @r1 = Review.create!(user: @u1, book: @b1, review_text: 'first', rating: 3)
    end

    it 'should have links from each site on index to the respective show page' do
      visit books_path
      within(find('#book-card', text: @b1.title)) do
        click_on 'More...'
      end
      expect(page.current_path).to eq(book_path(@b1))
      expect(page).to have_content('a_test1')
      expect(page).to have_content('test')

      visit books_path
      within(find('#book-card', text: @b2.title)) do
        click_on 'More...'
      end
      expect(page.current_path).to eq(book_path(@b2))
      expect(page).to have_content('b_test2')
      expect(page).to have_content('test')

      visit books_path
      within(find('#book-card', text: @b3.title)) do
        click_on 'More'
      end
      expect(page.current_path).to eq(book_path(@b3))
      expect(page).to have_content('c_test3')
      expect(page).to have_content('test')
    end

    it 'should have a link from show back to index' do
      visit book_path(@b2)
      click_on 'Back to index'
      expect(page.current_path).to eq(books_path)

      visit book_path(@b3)
      click_on 'Back to index'
      expect(page.current_path).to eq(books_path)
    end

    it 'should render details on the show page' do
      visit book_path(@b2)
      expect(page.text).to match(/b_test2/m)
      expect(page.text).to match(/test/im)
      expect(page).to have_content(/test/)
      expect(page).to have_content(/2222-02-02/)
    end
  end

  describe "show_google" do
    before(:each) do
      @user = User.create!(first: "John", last: "Doe", email: "john@example.com", password: "password", role: :admin)
      
      @google_book_data = OpenStruct.new(
        id: "google_1",
        title: "Google Book Title",
        author: "Google Author",
        description: "Google Book Description",
        genre: "Fiction",
        publisher: "Google Publisher",
        publish_date: "2022-01-01",
        pages: 300,
        language_written: "English",
        isbn_13: "1234567890123",
        image_url: "https://th.bing.com/th/id/OIP.caKIPkEzOmvoKgGoa-KXwgAAAA?w=135&h=206&c=7&r=0&o=5&dpr=2&pid=1.7"
      )
      
      allow_any_instance_of(BooksController).to receive(:fetch_books_from_google_books)
        .and_return([@google_book_data])
      
      # other methods... eventually...
    end
    
    it "displays the Google book details correctly" do
      visit show_google_book_path(id: "google_1", query: 'Testing')
      
      # Check that the book's title and other details are rendered on the page
      expect(page).to have_content("Google Book Title")
      expect(page).to have_content("Google Author")
      expect(page).to have_content("Google Book Description")
      expect(page).to have_content("Fiction")
      expect(page).to have_content("Google Publisher")
      expect(page).to have_content("2022-01-01")
      expect(page).to have_content("300 pages")
      expect(page).to have_content("English")
    end
    
    it "redirects to the existing book if it is already in the database" do

      Book.create!(title: "Google Book Title", author: "Google Author", genre: "Fiction", 
                  description: "Google Book Description", publisher: "Google Publisher", 
                  publish_date: Date.new(2022, 1, 1), isbn_13: "1234567890123")
      
      visit show_google_book_path(id: "google_1", query: 'Test Query')
      
      expect(page).to have_current_path(book_path(Book.last))
    end
    
    it "shows an error message if the Google book is not found" do

      allow_any_instance_of(BooksController).to receive(:fetch_books_from_google_books).and_return([])

      visit show_google_book_path(id: "google_1", query: 'Non-existent Query')

      expect(page).to have_content("Google book not found")
      expect(page).to have_current_path(books_path)
    end

    it "handles exceptions correctly" do
      allow_any_instance_of(BooksController).to receive(:fetch_books_from_google_books).and_raise(StandardError)

      visit show_google_book_path(id: "google_1", query: 'Test Query')

      expect(page).to have_content("Something went wrong while fetching Google Books data")
      expect(page).to have_current_path(books_path)
    end
  end

  describe "filtering within index" do 

    before(:each) do
      @u1 = User.create!(first: "Allie", last: "Amberson", 
                email: "aa@gmail.com", bio:"wassup", 
                password:"aamerson", role: :admin)
      @b1 = Book.create!(title: "a_test1", author: "test",
                  genre: "nonfiction", 
                  pages: 100, description: "test",
                  publisher: "test",
                  publish_date: Date.new(2222, 2, 2), isbn_13: 1111111111111, language_written: "test")
      @b2 = Book.create!(title: "b_test2", author: "test",
                  genre: "fiction", 
                  pages: 200, description: "test",
                  publisher: "test",
                  publish_date: Date.new(2222, 2, 2), isbn_13: 1111111111111, language_written: "test")
      @b3 = Book.create!(title: "c_test3", author: "test",
                  genre: "fiction", 
                  pages: 300, description: "test",
                  publisher: "test",
                  publish_date: Date.new(2222, 2, 2), isbn_13: 1111111111111, language_written: "test")
      @r2 = Review.create!(user: @u1, book: @b1, review_text: 'second', rating: 4)
      @r3 = Review.create!(user: @u1, book: @b2, review_text: 'third', rating: 3)
    end

    it "should allow the user to search by filling in query" do
      visit books_path
      fill_in 'query', with: 'b_test2'
      click_button 'Filter Books'
      expect(page.text).to match(/b_test2/i)
      expect(page.text).not_to match(/a_test1/i)
      expect(page.text).not_to match(/c_test3/i)
    end 

    it "should filter by average review" do
      visit books_path
      fill_in 'rating', with: '4'
      click_button 'Filter Books'
      expect(page.text).not_to match(/c_test3/i)
      expect(page.text).not_to match(/b_test2/i)
      expect(page.text).to match(/a_test1/i)

      fill_in 'rating', with: '3'
      click_button 'Filter Books'
      expect(page.text).not_to match(/c_test3/i)
      expect(page.text).to match(/b_test2/i)
      expect(page.text).to match(/a_test1/i)
    end


    it "should sort by rating" do
      visit books_path
      select 'Rating - Lowest to Highest', from: 'sort'
      click_button 'Filter Books'
      expect(page.text).to match(/a_test1/i)
      expect(page.text).to match(/b_test2/i)
      expect(page.text).not_to match(/c_test3/i)
    end

    it "should filter by genre" do
      visit books_path
      fill_in 'genre', with: 'fiction'
      click_button 'Filter Books'
      expect(page.text).to match(/c_test3/i)
      expect(page.text).to match(/b_test2/i)
      expect(page.text).not_to match(/a_test1/i)
    end
  end

  describe "destroy" do
    before(:each) do 
      @b1 = Book.create!(title: "a_test1", author: "test",
                genre: "nonfiction", 
                pages: 100, description: "test",
                publisher: "test",
                publish_date: Date.new(2222, 2, 2), isbn_13: 1111111111111, language_written: "test")
    end

    it "should destroy book" do #and associated review
      visit book_path(@b1)
      click_button 'Delete book (will need permissions)'
      expect(page).to have_content('Book deleted successfully')
      expect(page).not_to have_content('a_test1')
    end
  end
end
