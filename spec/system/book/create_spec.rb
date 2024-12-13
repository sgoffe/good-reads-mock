require 'rails_helper'
require 'simplecov'

RSpec.describe "Create Book", type: :system do
  before do
    driven_by(:rack_test)
  end

  describe "Creating a new book" do
    it 'successfully creates a book' do
      visit new_book_path
      fill_in 'Title', with: 'Test Book'
      fill_in 'Author', with: 'Test Author'
      fill_in 'Genre', with: 'Fiction'
      fill_in 'Pages', with: 100
      fill_in 'Description', with: 'A test description'
      fill_in 'Publisher', with: 'Test Publisher'
      fill_in 'Publish date', with: "2022-02-02"
      fill_in 'Isbn 13', with: "0000000000000"
      fill_in 'Language written', with: 'English'
      click_on 'Create Book'
      expect(page).to have_content('Book Test Book created successfully')
      expect(page.current_path).to eq(books_path)
      expect(page).to have_content('Test Book')
    end

    it 'fails to create a book when inputs are missing' do
      visit new_book_path
      click_on 'Create Book'
      expect(page.current_path).to eq(books_path) # assume no redirect, just renders 'new'
      expect(page).to have_content(/Book could not be created/)
    end
  end
end


