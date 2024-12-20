require 'rails_helper'

RSpec.describe "Show route", type: :system do
  before do
    driven_by(:rack_test)
  end

  describe "#show" do
    before(:each) do
      @u1 = User.create!(first: "user 2", last: "Amberson", email: "aa@gmail.com", bio:"wassup", password:"aamerson", role: :admin)
      sign_in @u1
      @b1 = FactoryBot.create(:book, genre: "fiction")
      # @b1 = Book.create!(title: "Dune", author: "test", genre: :fiction, pages: 100, description: "test", publisher: "test", 
      #                     publish_date: Date.new(2002, 2, 2), isbn_13: 1111111111111, language_written: "test")
      @r1 = Review.new(review_text: 'first', rating: 3)
      @r1.user = @u1
      @b1.reviews << @r1
      stub_request(:get, %r{https://www.googleapis.com/books/v1/volumes/.*})
      .with(
        headers: {
          'Accept' => '*/*',
          'Accept-Encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
          'User-Agent' => 'Ruby'
        }
      )
      .to_return(status: 200, body: "", headers: {})
    
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

        visit book_reviews_path(@b1)
      end
    end

    it 'should render details on the show page' do
      visit review_path(@r1.id)
      expect(page.text).to match(/user 2/m)
      expect(page.text).to match(/Sample Title/m)
      expect(page.text).to match(/first/m)
      expect(page.text).to match(/3/m)
    end

    it 'should have a link from show back to index' do
      id1 = @r1.id
      visit review_path(id1)
      click_on 'Back to index'
      expect(page.current_path).to eq(books_path)
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
      expect(page.current_path).to eq(books_path)
      expect(Review.exists?(id1)).to be(false)
    end
  end
end