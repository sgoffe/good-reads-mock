require 'rails_helper'

RSpec.describe User, type: :model do
  it "should respond to the required fields" do
    u = User.new
    expect(u).to respond_to(:first)
    expect(u).to respond_to(:last)
    expect(u).to respond_to(:email)
    expect(u).to respond_to(:bio)
  end


  it "should correctly create a user given all the required fields" do
    u = User.new(first: "Jounny", last: "Mademourn", email: "JMadyMorny@yahoo.com", bio: "I AM A LOVER OF BOOKS")
    expect(u.save).to be(true)
    expect(User.all.count).to eq(1)
  end
end
