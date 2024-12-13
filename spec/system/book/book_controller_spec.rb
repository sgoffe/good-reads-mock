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
                  publish_date: Date.new(2222, 2, 2), isbn_13: 1111111111111, language_written: "test",
                  img_url: "https://th.bing.com/th/id/OIP.caKIPkEzOmvoKgGoa-KXwgAAAA?w=135&h=206&c=7&r=0&o=5&dpr=2&pid=1.7"
                  )
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
      expect(page).to have_link('Back to index')
      click_on 'Back to index'
      expect(page.current_path).to eq(books_path)

      visit book_path(@b3)
      expect(page).to have_link('Back to index')
      click_on 'Back to index'
      expect(page.current_path).to eq(books_path)
    end

    it 'should render details on the show page' do
      visit book_path(@b2)
      expect(page).to have_content(@b2.title)
      expect(page).to have_content(@b2.author)
      expect(page).to have_content(@b2.genre)
      expect(page).to have_content(@b2.pages)
      expect(page).to have_content(@b2.description)
      expect(page).to have_content(@b2.publisher)
      expect(page).to have_content(@b2.publish_date)
      expect(page).to have_content(@b2.isbn_13)
      expect(page).to have_content(@b2.language_written)
    end

    it 'should have a image on the show page if there is one' do
      visit book_path(@b2)
      expect(page).to have_css("img[src='#{@b2.img_url}']")
    end

    it 'should have the default image on the show page if there is no image' do
      visit book_path(@b1)
      expect page.has_css?("img[src*='default_book.png']")
    end
  end
end
