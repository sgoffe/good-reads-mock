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
    sign_in @admin
    @b1 = FactoryBot.create(:book)
  end

  describe "create a new review" do
    it 'successful create' do
      sign_in @admin
      visit new_book_review_path(@b1)
      fill_in 'Rating', with: 4
      fill_in 'Review text', with: 'Test Review Text'
      click_on 'Submit Review'
      expect(page).to have_content('Review created successfully')
      expect(page.current_path).to eq(book_path(@b1.id))
      expect(page).to have_content('Sample Title')
    end

    it "handles failed create" do 
      r = Review.new
      allow(Review).to receive(:new).and_return(r)
      allow(r).to receive(:save).and_return(nil)

      visit new_book_review_path(@b1)
      fill_in 'Rating', with: 4
      fill_in 'Review text', with: 'Test Review Text'
      click_on 'Submit Review'
      expect(page).to have_content('Review could not be created')
    end
  end

  describe 'edit a review' do
    before (:each) do
      @r = Review.new(review_text: 'test 1', rating: 3)
      @r.user = @admin
      @b1.reviews << @r
      @r.save!
    end

    it 'successful update' do
      visit book_path(@b1)
      click_on @r.review_text
      expect(page).to have_content('test 1')
      click_on 'Edit'
      fill_in 'Review text', with: 'new review text'
      click_on 'Update Review'
      expect(page).to have_content('Review updated successfully') 
    end
    

    it "handles failed update" do
      allow(Review).to receive(:find).and_return(@r)
      allow(@r).to receive(:update).and_return(false)
    
      visit book_path(@b1)
      click_on @r.review_text
      expect(page).to have_content('test 1')
      click_on 'Edit'
      fill_in 'Review text', with: 'new review text'
      click_on 'Update Review'
      expect(page).to have_current_path(review_path(@r))      
      expect(page).to have_content('Review could not be edited')
    end
    
  end
end