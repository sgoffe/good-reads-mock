require 'rails_helper'

RSpec.describe "Show route", type: :system do
  before do
    driven_by(:rack_test)
  end
  
  before(:each) do
    @u1 = User.create!(first: "Allie", last: "Amberson", 
                email: "aa@gmail.com", bio:"wassup", 
                password:"aamerson", role: :admin)
    @b1 = Book.create!(title: "test", author: "test",
                genre: :fiction,
                pages: 100, description: "test",
                publisher: "test",
                publish_date: Date.new(2222, 2, 2), isbn_13: 1111111111111, language_written: "test")
  end

  describe "destroying a review" do
    it 'deletes a review' do
      expect(Review.all.count).to eq(0)
      review = Review.create!(user: @u1, book: @b1, description: 'test 1', rating: 3)
      visit review_path(review)
      expect(page).to have_content('test 1')
      click_on 'Delete'
      expect(page).to have_content('Review deleted successfully')
      expect(page).not_to have_content('test 1')
      expect(Review.all.count).to eq(0)
    end

    describe 'handles failed delete' do
      it 'due to db error' do
        r = Review.create!(user: @u1, book: @b1, description: 'test 1', rating: 3)
        allow_any_instance_of(Review).to receive(:destroy).and_raise(StandardError)
  
        visit review_path(r)
        click_on 'Delete'
        expect(page.current_path).to eq(review_path(r))
        expect(page).to have_content('Error deleting review')
      end

      it 'due to invalid id' do
        r = Review.create!(user: @u1, book: @b1, description: 'test 1', rating: 3)
        allow_any_instance_of(Review).to receive(:destroy).and_raise(ActiveRecord::RecordNotFound)

        visit review_path(r)
        click_on 'Delete'
        expect(page.current_path).to eq(reviews_path)
        expect(page).to have_content('Review not found')
      end
    end
  end
end