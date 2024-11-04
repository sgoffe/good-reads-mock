require 'rails_helper'
require 'simplecov'
SimpleCov.start 'rails'

RSpec.describe "NewCreateEditUpdate", type: :system do
  before do
    driven_by(:rack_test)
  end

  describe "create a new review " do
    it 'successful create' do
      visit new_review_path
      fill_in 'Book', with: 'Test Book'
      fill_in 'Rating', with: 4
      fill_in 'Description', with: 'Test Description'
      click_on 'Create Review'
      expect(page).to have_content('Review created successfully')
      expect(page.current_path).to eq(reviews_path)
      expect(page).to have_content('Test Book')
    end

    it "handles failed create" do 
      r = Review.new
      allow(Review).to receive(:new).and_return(r)
      allow(r).to receive(:save).and_return(nil)

      visit new_review_path
      fill_in 'Book', with: 'Test Book'
      fill_in 'Rating', with: 4
      fill_in 'Description', with: 'Test Description'
      click_on 'Create Review'

      expect(page).to have_content('Review could not be created')
    end
  end

  describe 'edit a sight' do
    before (:each) do
      @r = Review.create!(user: 'user 1', book: 'Dune', description: 'test 1', rating: 3)
    end

    it 'successful update' do
      visit reviews_path
      find("a[href='#{review_path(@r)}']").click
      expect(page).to have_content('test 1')
      click_on 'Edit'
      fill_in 'Description', with: 'new description'
      click_on 'Update Review'
      expect(page).to have_content('new description')
    end

    it "handles failed update" do
      allow(Review).to receive(:find).and_return(@r)
      allow(@r).to receive(:update).and_return(nil)

      visit reviews_path
      find("a[href='#{review_path(@r)}']").click
      expect(page).to have_content('test 1')
      click_on 'Edit'
      fill_in 'Description', with: 'new description'
      click_on 'Update Review'
      
      expect(page).to have_content('Review could not be edited')
    end
  end
end