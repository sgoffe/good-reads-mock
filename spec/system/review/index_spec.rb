require 'rails_helper'

RSpec.describe "Index route", type: :system do
  before do
    driven_by(:rack_test)
  end

  describe "#index" do
		before(:each) do
			@r1 = Review.create!(user: 'user 1', book: 'Dune', description: 'test 1', rating: 3)
			@r2 = Review.create!(user: 'user 2', book: 'Dune', description: 'test 2', rating: 2)
			@r3 = Review.create!(user: 'user 3', book: 'Dune', description: 'test 3', rating: 5)
		end

		it 'should render all reviews, ordered by publish date in descending order' do
			visit reviews_path
			review_links = all('a.btn.btn-sm.btn-primary') 
			expect(review_links.size).to eq(3)  
	
			expect(review_links[0][:href]).to eq(review_path(@r3)) 
			expect(review_links[1][:href]).to eq(review_path(@r2))  
			expect(review_links[2][:href]).to eq(review_path(@r1)) 
		end
	end
end