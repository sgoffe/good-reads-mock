require 'rails_helper'

RSpec.describe Friendship, type: :model do
  it "should respond to the required fields" do
    f = Friendship.new
    expect(f).to respond_to(:user_id)
    expect(f).to respond_to(:friend_id)
  end


  it "should correctly create a friendship given all the required fields" do
    u = User.new(first: "Jounny", last: "Mademourn", email: "JMadyMorny@yahoo.com", bio: "I AM A LOVER OF BOOKS", password: "jmademourn")
    u2 = User.new(first: "Markie", last: "Mademourn", email: "MMadyMorny@yahoo.com", bio: "I AM ALSO A LOVER OF BOOKS", password: "mmademourn")
    expect(u.save).to be(true)
    expect(u2.save).to be(true)
    expect(User.all.count).to eq(2)
    f = Friendship.new(user_id: 1, friend_id: 2)
    expect(f.save).to be(true)
    expect(Friendship.all.count).to eq(1)
    expect(f.user_id).to eq(1)
    expect(f.friend_id).to eq(2)
  end
end