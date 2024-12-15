require 'rails_helper'

RSpec.describe "Show route", type: :system do
  before do
    driven_by(:rack_test)
  end

  describe "#show" do
    before(:each) do
      @u1 = User.create!(first: "user 2", last: "Amberson", email: "aa@gmail.com", bio:"wassup", password:"aamerson", role: :admin)
      @b1 = Book.create!(title: "Dune", author: "test", genre: :fiction, pages: 100, description: "test", publisher: "test", 
                          publish_date: Date.new(2002, 2, 2), isbn_13: 1111111111111, language_written: "test")
      @r1 = Review.new(review_text: 'first', rating: 3)
      @r1.user = @u1
      @b1.reviews << @r1
    end

    it "navigates to the correct review show page when clicking 'More'" do
      visit book_reviews_path(@b1.id)

      Review.all.each do |review|
        find("a[href='#{review_path(review)}']").click

        expect(current_path).to eq(review_path(review))
        expect(page).to have_content(review.user.first)
        expect(page).to have_content(review.book.title)
        expect(page).to have_content(review.review_text)
        expect(page).to have_content(review.rating)

        visit book_reviews_path(@b1.id)
      end
    end

    it 'should render details on the show page' do
      visit review_path(@r1.id)
      expect(page.text).to match(/user 2/m)
      expect(page.text).to match(/Dune/m)
      expect(page.text).to match(/first/m)
      expect(page.text).to match(/3/m)
    end

    it 'should have a link from show back to index' do
      id1 = @r1.id
      visit review_path(id1)
      click_on 'Back to index'
      expect(page.current_path).to eq(reviews_path)
    end

    it 'should have a link to edit' do
      id1 = @r1.id
      visit review_path(id1)
      click_on 'Edit'
      expect(page.current_path).to match(edit_review_path(id1))
    end

    it 'should have a button to delete' do
      id1 = @r1.id
      visit review_path(id1)
      click_on 'Delete'
      expect(page.current_path).to eq(reviews_path)
      expect(Review.exists?(id1)).to be(false)
    end
  end
end