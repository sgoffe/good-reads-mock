require 'rails_helper'

RSpec.describe "Recommend", type: :system do
  include Devise::Test::IntegrationHelpers

  before do
    driven_by(:rack_test)
  end

  before(:each) do
    @sender = create(:user)
    @receiver = create(:user)
    @b1 = create(:book)
    @n1 = Notification.new(
      sender: @sender,
      receiver: @receiver,
      title: "Book Recommendation",
      notifiable: @b1
    )

  end

  describe "recommending a book" do 

    it "should allow a logged-in user to recommend a book to another user" do
      visit book_path(@b1)
      sign_in @sender
      click_on "Recommend this book"
      select @receiver.first, from: "Select a Friend"
      fill_in "Message", with: "Hey Ron, I think you'll love this book!"
      click_on "Send Recommendation"
      expect(page.current_path).to eq(book_path(@b1))
      expect(page).to have_content("Recommendation sent!")
    end

    it "should allow a logged-in user to view their recommended notifications" do
      visit user_path(@receiver)
      sign_in @receiver
      click_on "Inbox"
      expect(page.current_path).to eq(user_notifications_path(@receiver))
      expect(page).to have_selector('#title', text: "#{@sender.first} #{@sender.last} recommended #{@b1.title} to you")
      expect(page).to have_link(nil, href: @n1.notification_url)
    end

    it "should allow a logged-in user to recommend a book to another user (sad path)" do
      allow(@n1).to receive(:save).and_return(false)
      allow(Notification).to receive(:new).and_return(@n1)

      visit book_path(@b1)
      sign_in @sender
      click_on "Recommend this book"
      select @receiver.first, from: "Select a Friend"
      fill_in "Message", with: "Hey Ron, I think you'll love this book!"
      click_on "Send Recommendation"
      expect(page.current_path).to eq(book_path(@b1))
      expect(page).to have_content("There was an error sending the recommendation.")
    end

    it "should only allow a user to view their own notifications" do
      visit book_path(@b1)
      sign_in @sender
      visit  user_notifications_path(@receiver)
      expect(page.current_path).to eq(root_path)
      expect(page).to have_content("You are not authorized to view this page.")
    end
  end
end