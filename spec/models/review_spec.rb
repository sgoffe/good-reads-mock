require 'rails_helper'

RSpec.describe Review, type: :model do
  describe "model attributes" do
    it "should respond to required attribute methods" do
      s = Review.new
      expect(s).to respond_to(:user)
      expect(s).to respond_to(:book)
      expect(s).to respond_to(:rating)
      expect(s).to respond_to(:description)
    end

    it "should allow creation of model objects with all attributes" do
      r = Review.new(user: 'user 1', book: 'book 1', rating: 4, description: 'test 1')
      expect(r.save).to be true
      expect(Review.all.count).to eq(1)
    end
  end

  describe "validations" do
    it "should require a user" do
      r = Review.new(book: 'book 1', rating: 4, description: 'test 1')
      expect(r.save).to be false
    end

    it "should require an book" do
      r = Review.new(user: 'user 1', rating: 4, description: 'test 1')
      expect(r.save).to be false
    end

    it "should require a rating" do
      r = Review.new(user: 'user 1', book: 'book 1', description: 'test 1')
      expect(r.save).to be false
    end

    it "should require a description" do
      r = Review.new(user: 'user 1', book: 'book 1', rating: 4)
      expect(r.save).to be false
    end
  end
end
