require 'rails_helper'

RSpec.describe "Show route", type: :system do
  before do
    driven_by(:rack_test)
  end

  describe "#show" do
    before(:each) do
      @u1 = User.create!(first: "user 2", last: "Amberson", email: "aa@gmail.com", bio:"wassup", password:"aamerson", role: :admin)
      @b1 = Book.create!(title: "Dune", author: "test", genre: :fiction, pages: 100, description: "test", publisher: "test", 
                          publish_date: Date.new(2222, 2, 2), isbn_13: 1111111111111, language_written: "test")
      @r1 = Review.new(review_text: 'first', rating: 3)
      @r1.user = @u1
      @b1.reviews << @r1
    end

    it "navigates to the correct review show page when clicking 'More'" do
      visit books_reviews_path(@b1.id)

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
      visit book_review_path(@r1.id)
      expect(page.text).to match(/user 1/m)
      expect(page.text).to match(/Dune/m)
      expect(page.text).to match(/test 1/m)
      expect(page.text).to match(/1/m)
    end

    it 'should have a link from show back to index' do
      visit review_path(@r2)
      click_on 'Back to index'
      expect(page.current_path).to eq(reviews_path)

      visit review_path(@r3)
      click_on 'Back to index'
      expect(page.current_path).to eq(reviews_path)
    end

    it 'should have a link to edit' do
      visit book_review_path(@r1)
      click_on 'More'
      click_on 'Edit'
      expect(page.current_path).to eq(edit_review_path(@r1))
    end

    it 'should have a button to delete' do
      id1 = @r1.id
      visit review_path(@r1)
      click_on 'Delete'
      expect(page.current_path).to eq(reviews_path)
      expect(Review.exists?(id1)).to be(false)

      id2 = @r2.id
      visit review_path(@r2)
      click_on 'Delete'
      expect(page.current_path).to eq(reviews_path)
      expect(Review.exists?(id2)).to be(false)
    end
  end
end