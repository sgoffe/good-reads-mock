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
    it "should require a description" do
      r = Review.new(user: "John Doe", book: "Dune", rating: 4)

      expect(r.save).to be false
    end

    it "should require a rating" do
      r = Review.new(user: "John Doe", book: "Dune", description: "test")

      expect(r.save).to be false
    end
  end

  # describe "#index" do
  #   before(:each) do
  #     Review.create!(user: 'user1',
  #                   book: 'Dune',
  #                   rating: 5,
  #                   description: 'currently my favorite book')
  #     Review.create!(user: 'user2',
  #                   book: 'Dune',
  #                   rating: 3,
  #                   description: 'The movie is better')
  #     Review.create!(user: 'user3',
  #                   book: 'Dune',
  #                   rating: 3,
  #                   description: 'disturbed')
  #   end

  #   it "should order by post date if not specified" do
  #     visit reviews_path
  #     click_on 'Order By'

  #   end

  #   it "should order by rating if specified" do 
  #   end
  # end
end
