require 'rails_helper'

RSpec.describe "Index route", type: :system do
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
		publish_date: Date.new(2002, 2, 2), isbn_13: 1111111111111, language_written: "test")
	
	
	@r1 = Review.create!(user: @u1, book: @b1, review_text: 'first', rating: 3)
	@r2 = Review.create!(user: @u1, book: @b1, review_text: 'second', rating: 3)
	@r3 = Review.create!(user: @u1, book: @b1, review_text: 'third', rating: 3)
end

	describe "#index" do
		it 'should render all reviews, ordered by publish date in descending order' do
			visit reviews_path
			review_links = all('a.btn.btn-sm.btn-primary.more-btn') 
			expect(review_links.size).to eq(3)  

			expect(review_links[0][:href]).to eq(review_path(@r3)) 
			expect(review_links[1][:href]).to eq(review_path(@r2))  
			expect(review_links[2][:href]).to eq(review_path(@r1)) 
		end
	end
end