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

    @book = FactoryBot.create(:book, title: "a_test1", author: "test", genre: "fiction", publisher: "test", publish_date: Date.new(2000, 2, 2), language_written: "test", pages: 100, img_url: nil)

    @recommendation_notification = Notification.create!(
      sender: @sender,
      receiver: @receiver,
      title: "<strong>#{@sender.first} #{@sender.last}</strong> recommended <strong>#{@book.title}</strong> to you!",
      message: "hi there",
      notifiable_type: 'Book',
      notifiable: @book 
    )

    @friendship_notification = Notification.create!(
      sender: @sender,
      receiver: @receiver,
      title: "<strong>#{@sender.first} #{@sender.last}</strong> added you as a friend!",
      message: " ",
      notifiable_type: 'User',
      notifiable: @sender 
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

  describe "formatted_title" do
    it "should format title correctly when notifiable type is 'Book'" do
      expect(@recommendation_notification.formatted_title).to eq("<strong>Harry Potter</strong> recommended <strong>a_test1</strong> to you")
    end

    it "should format notif title correctly when notifiable type is 'User'" do
      expect(@friendship_notification.formatted_title).to eq("<strong>Harry Potter</strong> added you as a friend!")
    end
  end

  describe "notification_url" do
    it "should format correct link when notifiable type is 'Book'" do
      expect(@recommendation_notification.notification_url).to eq(book_path(@book))
    end

    it "should format correct link when notifiable type is 'User'" do
      expect(@friendship_notification.notification_url).to eq(user_path(@sender))
    end
  end
end
