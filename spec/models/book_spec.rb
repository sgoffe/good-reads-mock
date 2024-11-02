require 'rails_helper'

RSpec.describe Book, type: :model do
  describe "model attributes" do
    it "should respond to requied attribute methods" do
      b = Book.new
      expect(b).to respond_to(:title)
      expect(b).to respond_to(:author)
      expect(b).to respond_to(:genre)
      expect(b).to respond_to(:pages)
      expect(b).to respond_to(:description)
      expect(b).to respond_to(:publisher)
      expect(b).to respond_to(:publish_date)
      expect(b).to respond_to(:isbn_13)
      expect(b).to respond_to(:language_written)
    end

    it "should allow creation of model objects with all attributes" do
      b = Book.new(title: "test", author: "test",
                  genre: :fiction,
                  pages: 100, description: "test",
                  publisher: "test",
                  publish_date: Date.new(2222, 2, 2), isbn_13: 1111111111111, language_written: "test")
      expect(b.save).to be true
      expect(Book.all.count).to eq(1)
    end

    it "should have the correct enumeration for attraction_type" do
      expect(Book.genres.keys).to include("historical_fiction")
      expect(Book.genres.keys).to include("fiction")
      expect(Book.genres.keys).to include("horror")
      expect(Book.genres.keys).to include("romance")
      expect(Book.genres.keys).to include("comedy")
      expect(Book.genres.keys).to include("thriller")
      expect(Book.genres.keys).to include("young_adult")
      expect(Book.genres.keys).to include("science_fiction")
      expect(Book.genres.keys).to include("mystery")
      expect(Book.genres.keys).to include("nonfiction")
    end

    # should work eventually 

    # it "should allow attachment of images" do
    #   s = Sight.new(title: "test", description: "test",
    #               entrance_fee: 1.0, attraction_type: :museum,
    #               address: 'Duluth, MN', telephone: '1234567890',
    #               open_time: DateTime.parse('8 am').to_time,
    #               close_time: DateTime.parse('9 am').to_time)
    #   s.images.attach(io: File.open('spec/testimg.jpg'), filename: 'testimg.jpg')
    #   expect(s.save).to be true
    #   expect(s.images.count).to eq(1)
    #   expect(Sight.all.count).to eq(1)
    # end

  end

  describe "validations" do
    it "should require a title" do
      b = Book.new(author: "test",
                  genre: :fiction,
                  pages: 100, description: "test",
                  publisher: "test",
                  publish_date: Date.new(2222, 2, 2), isbn_13: 1111111111111, language_written: "test")
      expect(b.save).to be false
    end

    it "should require an author" do
      b = Book.new(title: "test", 
                  genre: :fiction,
                  pages: 100, description: "test",
                  publisher: "test",
                  publish_date: Date.new(2222, 2, 2), isbn_13: 1111111111111, language_written: "test")
      expect(b.save).to be false
    end

    it "should require a genre" do
      b = Book.new(title: "test", author: "test",
                  pages: 100, description: "test",
                  publisher: "test",
                  publish_date: Date.new(2222, 2, 2), isbn_13: 1111111111111, language_written: "test")
      expect(b.save).to be false
    end

    it "should require a non-negative page count" do
      b = Book.new(title: "test", author: "test",
                  genre: :fiction,
                  pages: -2, description: "test",
                  publisher: "test",
                  publish_date: Date.new(2222, 2, 2), isbn_13: 1111111111111, language_written: "test")
      expect(b.save).to be false
    end

    it "should require a description" do
      b = Book.new(title: "test", author: "test",
                  genre: :fiction,
                  pages: 100, 
                  publisher: "test",
                  publish_date: Date.new(2222, 2, 2), isbn_13: 1111111111111, language_written: "test")
      expect(b.save).to be false
    end

    it "should require a publisher" do
      b = Book.new(title: "test", author: "test",
                  genre: :fiction,
                  pages: 100, description: "test",
                  publish_date: Date.new(2222, 2, 2), isbn_13: 1111111111111, language_written: "test")
      expect(b.save).to be false
    end
    
    #have to wait for emily to fix the date entry in new to implement the validation
    #in the controller and this test

    #maybe should also check that date is not beyond current date

    # it "should require a publish_date" do
    #   b = Book.new(title: "test", author: "test",
    #               genre: :fiction,
    #               pages: 100, description: "test",
    #               publisher: "test",
    #               isbn_13: 1111111111111, language_written: "test")
    #   expect(b.save).to be false
    # end

    #should in the future require a 13 digit isbn?
    it "should require an isbn_13" do
      b = Book.new(title: "test", author: "test",
                  genre: :fiction,
                  pages: 100, description: "test",
                  publisher: "test",
                  publish_date: Date.new(2222, 2, 2), language_written: "test")
      expect(b.save).to be false
    end
    it "should require a language" do
      b = Book.new(title: "test", author: "test",
                  genre: :fiction,
                  pages: 100, description: "test",
                  publisher: "test",
                  publish_date: Date.new(2222, 2, 2), isbn_13: 1111111111111)
      expect(b.save).to be false
    end
  end

  describe "#pages_less_than_or_eq_to?(pagecount)" do
    before(:each) do
      Book.create!(title: "a_test1", author: "test",
                  genre: :fiction,
                  pages: 100, description: "test",
                  publisher: "test",
                  publish_date: Date.new(2222, 2, 2), isbn_13: 1111111111111, language_written: "test")
      Book.create!(title: "b_test2", author: "test",
                  genre: :fiction,
                  pages: 200, description: "test",
                  publisher: "test",
                  publish_date: Date.new(2222, 2, 2), isbn_13: 1111111111111, language_written: "test")
      Book.create!(title: "c_test3", author: "test",
                  genre: :fiction,
                  pages: 300, description: "test",
                  publisher: "test",
                  publish_date: Date.new(2222, 2, 2), isbn_13: 1111111111111, language_written: "test")
    end

    it "should return zero books when passed a negative page count" do
      expect(Book.pages_less_than_or_eq_to?(-1).count).to eq(0)
    end

    it "should return all books ordered by title when passed page count greater than the page count of all books" do
      expect(Book.pages_less_than_or_eq_to?(500).count).to eq(3)
      expect(Book.pages_less_than_or_eq_to?(500).first.title).to eq("a_test1")
    end

    it "should return one book when passed its exact page count" do
      expect(Book.pages_less_than_or_eq_to?(100).count).to eq(1)
    end
  end

  describe "#by_search_string(substr)" do
    before(:each) do
      Book.create!(title: "a_test1", author: "test1_auth",
                  genre: :fiction,
                  pages: 100, description: "desc_test1",
                  publisher: "test",
                  publish_date: Date.new(2222, 2, 2), isbn_13: 1111111111111, language_written: "test")
      Book.create!(title: "b_test2", author: "test2_auth",
                  genre: :nonfiction,
                  pages: 200, description: "desc_test2",
                  publisher: "test",
                  publish_date: Date.new(2222, 2, 2), isbn_13: 1111111111111, language_written: "test")
      Book.create!(title: "c_test3", author: "test3_auth",
                  genre: :historical_fiction,
                  pages: 300, description: "a_test1",
                  publisher: "test",
                  publish_date: Date.new(2222, 2, 2), isbn_13: 1111111111111, language_written: "test")
    end

    it "should return zero books for a string that doesn't match" do
      expect(Book.by_search_string('nothing').count).to eq(0)
    end

    it "should return one book for a string matching title" do
      expect(Book.by_search_string('c_test3').count).to eq(1)
    end

    it "should return one book for a string matching description" do
      expect(Book.by_search_string('desc_test2').count).to eq(1)
    end

    it "should return two books ordered by titlefor a string matching title of one, desc of another" do
      expect(Book.by_search_string('a_test1').count).to eq(2)
      expect(Book.by_search_string('a_test1').first.title).to eq("a_test1")
    end

  end
end