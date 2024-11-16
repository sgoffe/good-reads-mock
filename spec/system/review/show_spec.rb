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
      # @r1 = Review.create!(user: @u1, book: @b1, description: 'first', rating: 3)
      @r1 = Review.create!(user: @u1, book: @b1, description: 'test 1', rating: 3)
      @r2 = Review.create!(user: @u1, book: @b1, description: 'test 2', rating: 2)
      @r3 = Review.create!(user: @u1, book: @b1, description: 'test 3', rating: 5)  
    end

    it "navigates to the correct review show page when clicking 'More'" do
      visit reviews_path

      Review.all.each do |review|
        find("a[href='#{review_path(review)}']").click

        expect(current_path).to eq(review_path(review))
        expect(page).to have_content(review.user.first)
        expect(page).to have_content(review.book.title)
        expect(page).to have_content(review.description)
        expect(page).to have_content(review.rating)

        visit reviews_path
      end
    end

    it 'should render details on the show page' do
      visit review_path(@r2)
      expect(page.text).to match(/user 2/m)
      expect(page.text).to match(/Dune/m)
      expect(page.text).to match(/test 2/m)
      expect(page.text).to match(/2/m)
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
      visit review_path(@r1)
      click_on 'Edit'
      expect(page.current_path).to eq(edit_review_path(@r1))

      visit review_path(@r2)
      click_on 'Edit'
      expect(page.current_path).to eq(edit_review_path(@r2))
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