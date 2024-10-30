require 'rails_helper'

RSpec.describe Review, type: :model do
  describe "model attributes" do
    it "should respond to required attribute methods" do
      r = Review.new
      expect(r).to respond_to(:user)
      expect(r).to respond_to(:book)
      expect(r).to respond_to(:rating)
      expect(r).to respond_to(:description)
    end
  end

  describe "validations" do
    it "should require a user" do
      r = Review.new(book: "Dune", description: "test", rating: 4)

      expect(r.save).to be false
    end

    it "should require a book" do
      r = Review.new(user: "John Doe", description: "test", rating: 4)

      expect(r.save).to be false
    end

    it "should require a description" do
      r = Review.new(user: "John Doe", book: "Dune", rating: 4)

      expect(r.save).to be false
    end

    it "should require a rating" do
      r = Review.new(user: "John Doe", book: "Dune", description: "test")

      expect(r.save).to be false
    end

  end
end
