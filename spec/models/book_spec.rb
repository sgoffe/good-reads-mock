require 'rails_helper'

RSpec.describe Book, type: :model do
  describe "model attributes" do
    it { should respond_to(:title, :author, :genre, :pages, :description, :publisher, :publish_date, :isbn_13, :language_written, :img_url) }

    it "should allow creation of model objects with all attributes" do
      b = Book.new(
        title: "test", author: "test", genre: :fiction, pages: 100, description: "test", publisher: "test", 
        publish_date: Date.new(2000, 2, 2), isbn_13: "1111111111111", language_written: "test", 
        img_url: "https://th.bing.com/th/id/OIP.caKIPkEzOmvoKgGoa-KXwgAAAA?w=135&h=206&c=7&r=0&o=5&dpr=2&pid=1.7"
      )
      expect(b.save).to be true
      expect(Book.count).to eq(1)
    end
  end

  describe "validations" do
    let(:valid_attributes) {
      { title: "test", author: "test", genre: :fiction, pages: 100, description: "test", publisher: "test", 
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
  end

  describe "custom methods" do
    before(:each) do
      @b1 = Book.create!(title: "a_test1", author: "test", genre: :fiction, pages: 100, description: "test", publisher: "test", 
                        publish_date: Date.new(2000, 2, 2), isbn_13: "2222222222222", language_written: "test")
      @b2 = Book.create!(title: "b_test2", author: "test", genre: :fiction, pages: 200, description: "test", publisher: "test", 
                        publish_date: Date.new(2000, 2, 2), isbn_13: "3333333333333", language_written: "test")
    end

    describe "#pages_less_than_or_eq_to?" do
      it "returns books with pages less than or equal to given count" do
        expect(Book.pages_less_than_or_eq_to?(150).count).to eq(1)
      end
    end

    describe "#by_search_string" do
      it "returns books matching the search string in title or description" do
        expect(Book.by_search_string('test1').count).to eq(1)
      end
    end

    describe "#with_average_rating" do
      before(:each) do
        @u = User.create!(first: "Test", last: "User", email: "test@user.com", password: "password")
        @r1 = Review.create!(user: @u, book: @b1, rating: 3, review_text: "test")
      end

      it "returns books with ratings greater than or equal to the specified value" do
        result = Book.with_average_rating(3)
        expect(result).to include(@b1)
      end
    end

    describe "#rating" do
      before(:each) do
        @u = User.create!(first: "Test", last: "User", email: "test@user.com", password: "password")
        @b1 = Book.create!(title: "a_test1", author: "test", genre: :fiction, pages: 100, description: "test", publisher: "test",
                          publish_date: Date.new(2000, 2, 2), isbn_13: "4444444444444", language_written: "test")
        @b2 = Book.create!(title: "b_test2", author: "test", genre: :fiction, pages: 200, description: "test", publisher: "test",
                          publish_date: Date.new(2000, 2, 2), isbn_13: "5555555555555", language_written: "test")
        @r1 = Review.create!(user: @u, book: @b1, rating: 4, review_text: "Great book!")
      end
    
      it "returns books with reviews" do
        expect(Book.rating).to include(@b1)
        expect(Book.rating).not_to include(@b2)
      end
    end
  
    describe "#in_genre" do
      it "returns books in the specified genre" do
        expect(Book.in_genre("fiction").count).to eq(2)
      end
    end
  end
end