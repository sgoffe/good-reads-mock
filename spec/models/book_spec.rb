require 'rails_helper'

RSpec.describe Book, type: :model do
  describe "model attributes" do
    it { should respond_to(:title, :google_books_id ,:author, :genre, :pages, :description, :publisher, :publish_date, :isbn_13, :language_written, :img_url) }

    it "should allow creation of model objects with all attributes" do
      b = Book.new(
        google_books_id: "test_google_id",
        title: "test",
        author: "test",
        genre: "fiction",
        pages: 100,
        description: "test",
        publisher: "test",
        publish_date: Date.new(2000, 2, 2),
        isbn_13: "1111111111111",
        language_written: "test",
        img_url: "https://th.bing.com/th/id/OIP.caKIPkEzOmvoKgGoa-KXwgAAAA?w=135&h=206&c=7&r=0&o=5&dpr=2&pid=1.7"
      )
      expect(b.save).to be true
      expect(Book.count).to eq(1)
    end
  end

  describe "validations" do
    let(:valid_attributes) {
      { title: "test", author: "test", genre: "fiction", pages: 100, description: "test", publisher: "test", 
        publish_date: Date.new(2000, 2, 2), isbn_13: "2111111111111", language_written: "test" }
    }

    it "validates presence of required attributes" do
      required_fields = [:title, :author, :genre, :pages, :description, :publisher, :isbn_13, :language_written]
      required_fields.each do |field|
        b = Book.new(valid_attributes.except(field))
        expect(b.save).to be false
      end
    end

    it "validates non-negative page count" do
      b = Book.new(valid_attributes.merge(pages: -2))
      expect(b.save).to be false
    end

    context 'when publish_date is in the past or today' do
      it 'is valid if the publish_date is today' do
        book = FactoryBot.build(:book, publish_date: Date.today)
        expect(book).to be_valid
      end

      it 'is valid if the publish_date is in the past' do
        book = FactoryBot.build(:book, publish_date: Date.yesterday)
        # book = Book.new(
        #   title: 'Past Book',
        #   author: 'Past Author',
        #   genre: 'Past Genre',
        #   pages: 100,
        #   description: 'Past Description',
        #   publisher: 'Past Publisher',
        #   publish_date: Date.yesterday,
        #   isbn_13: '1234567890123',
        #   language_written: 'English'
        # )
        
        expect(book).to be_valid
      end
    end

    context 'when publish_date is in the future' do
      it 'is invalid if the publish_date is in the future' do
        book = FactoryBot.build(:book, publish_date: Date.tomorrow)
        # book = Book.new(
        #   title: 'Future Book',
        #   author: 'Future Author',
        #   genre: 'Future Genre',
        #   pages: 100,
        #   description: 'Future Description',
        #   publisher: 'Future Publisher',
        #   publish_date: Date.tomorrow,
        #   isbn_13: '1234567890123',
        #   language_written: 'English'
        # )

        expect(book).to be_invalid
        expect(book.errors[:publish_date]).to include("can't be in the future")
      end
    end
  end

  describe "custom methods" do
    before(:each) do
      # @b1 = Book.create!(title: "a_test1", author: "test", genre: :fiction, pages: 100, description: "test", publisher: "test", 
      #                   publish_date: Date.new(2000, 2, 2), isbn_13: "2222222222222", language_written: "test")
      # @b2 = Book.create!(title: "b_test2", author: "test", genre: :fiction, pages: 200, description: "test", publisher: "test", 
      #                   publish_date: Date.new(2000, 2, 2), isbn_13: "3333333333333", language_written: "test")
      @b1 = FactoryBot.create(:book, title: "a_test1", author: "test", genre: "fiction", publisher: "test", publish_date: Date.new(2000, 2, 2), language_written: "test", pages: 100, img_url: nil)
      @b2 = FactoryBot.create(:book, pages: 200, title: "b_test2", author: "test", genre: "non-fiction", publisher: "test", publish_date: Date.new(2000, 2, 2), language_written: "test", img_url: nil)
    end

    describe "#pages_less_than_or_eq_to?" do
      it "returns books with pages less than or equal to given count" do
        expect(Book.pages_less_than_or_eq_to?(150).count).to eq(1)
      end
    end

    describe "#by_search_string" do
      it "returns books matching the search string in title or description" do
        expect(Book.by_search_string(@b1.title).count).to eq(1)
      end
    end

    describe "#with_average_rating" do
      before(:each) do
        @u = User.create!(first: "Test", last: "User", email: "test@user.com", password: "password")
        @r1 = Review.create!(user: @u, book: @b1, rating: 3, review_text: "test")
      end

      it "returns books with ratings greater than or equal to the specified value" do
        result = Book.with_average_rating(@r1.rating)
        expect(result).to include(@b1)
      end
    end

    describe "#rating" do
      before(:each) do
        @u = User.create!(first: "Test", last: "User", email: "test@user.com", password: "password")
        # @b1 = Book.create!(title: "a_test1", author: "test", genre: :fiction, pages: 100, description: "test", publisher: "test",
        #                   publish_date: Date.new(2000, 2, 2), isbn_13: "4444444444444", language_written: "test")
        # @b2 = Book.create!(title: "b_test2", author: "test", genre: :fiction, pages: 200, description: "test", publisher: "test",
        #                   publish_date: Date.new(2000, 2, 2), isbn_13: "5555555555555", language_written: "test")
        @b1 = FactoryBot.create(:book, genre: "fiction")
        @b2 = FactoryBot.create(:book, genre: @b1.genre)
        @b3 = FactoryBot.create(:book, genre: "politics")
        @r1 = Review.create!(user: @u, book: @b1, rating: 4, review_text: "Great book!")
      end
    
      it "returns books with reviews" do
        expect(Book.rating).to include(@b1)
        expect(Book.rating).not_to include(@b2)
        expect(Book.rating).not_to include(@b3)
      end
    end
  
    describe "#in_genre" do
      before(:each) do
        @b1 = FactoryBot.create(:book, genre: "#in_genre test")
        @b2 = FactoryBot.create(:book, genre: @b1.genre)
        @b3 = FactoryBot.create(:book, genre: "#in_genre test 2")
      end
      it "returns books in the specified genre" do
        expect(Book.in_genre(@b1.genre).count).to eq(2)
        expect(Book.in_genre(@b3.genre).count).to eq(1)
      end
    end
  end
end