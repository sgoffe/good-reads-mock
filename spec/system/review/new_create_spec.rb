require 'rails_helper'

RSpec.describe "NewCreateEditUpdate", type: :system do
  include Devise::Test::IntegrationHelpers

  before do
    driven_by(:rack_test)
  end

  before(:each) do
    @admin = User.create!(first: "Allie", last: "Amberson", 
      email: "aa@gmail.com", bio:"wassup", 
      password:"aamerson", role: :admin)
    @b1 = Book.create!(title: "Test Book", author: "test",
      genre: :fiction,
      pages: 100, description: "test",
      publisher: "test",
      publish_date: Date.new(2222, 2, 2), isbn_13: 1111111111111, language_written: "test")
    # @r1 = Review.create!(user: @u1, book: @b1, review_text: 'first', rating: 3)
  end

  describe "create a new review" do
    it 'successful create' do
      sign_in @admin
      visit new_book_review_path(@b1)
      fill_in 'Rating', with: 4
      fill_in 'Review text', with: 'Test Review Text'
      click_on 'Create Review'
      expect(page).to have_content('Review created successfully')
      expect(page.current_path).to eq(book_path(@b1.id))
      expect(page).to have_content('Test Book')
    end

    it "handles failed create" do 
      r = Review.new
      allow(Review).to receive(:new).and_return(r)
      allow(r).to receive(:save).and_return(nil)

      visit new_book_review_path(@b1.id)
      fill_in 'Rating', with: 4
      fill_in 'Review text', with: 'Test Review Text'
      click_on 'Create Review'

      expect(page).to have_content('Review could not be created')
    end
  end

  describe 'edit a review' do
    before (:each) do
      @r = Review.create!(user: 'user 1', book: 'Dune', review_text: 'test 1', rating: 3)
    end

    it 'successful update' do
      visit reviews_path
      find("a[href='#{review_path(@r)}']").click
      expect(page).to have_content('test 1')
      click_on 'Edit'
      fill_in 'Review text', with: 'new review text'
      click_on 'Update Review'
      expect(page).to have_content('new review text')
    end

    it "handles failed update" do
      allow(Review).to receive(:find).and_return(@r)
      allow(@r).to receive(:update).and_return(nil)

      visit reviews_path
      find("a[href='#{review_path(@r)}']").click
      expect(page).to have_content('test 1')
      click_on 'Edit'
      fill_in 'Review text', with: 'new review text'
      click_on 'Update Review'
      
      expect(page).to have_content('Review could not be edited')
    end
  end
end