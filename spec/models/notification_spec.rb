require 'rails_helper'

RSpec.describe Notification, type: :model do
  before(:each) do
    @sender = User.create!(
      first: 'Harry',
      last: 'Potter',
      email: 'hpotter@colgate.edu',
      password: 'colgate13',
      role: :standard,
    )

    @receiver = User.create!(
      first: 'Ron',
      last: 'Weasley',
      email: 'rweasley@colgate.edu',
      password: 'colgate13',
      role: :standard,
    )
  end

  describe "validations" do 
    it "should not allow a sender a reciever to be the same" do

      user = FactoryBot.build(:user)
      notification = Notification.new(
        sender: user,
        receiver: user,
        title: "Test Notification",
        notifiable: create(:book)
      )

      expect(notification.valid?).to be_falsey
      expect(notification.errors[:receiver]).to include("can't be the same as sender")   
    end


    it "should be valid when sender and reciever are not the same" do
      
      notification = Notification.new(
        sender: create(:user),
        receiver: create(:user),
        title: "Book Recommendation",
        notifiable: create(:book)
      )
      
      expect(notification).to be_valid

    end
  end
end
