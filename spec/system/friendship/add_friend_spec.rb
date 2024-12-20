require 'rails_helper'

RSpec.describe "AddFriend", type: :system do
    before do
        driven_by(:rack_test)
    end

    before(:each) do
        @u1 = User.create!(first: "Allie", last: "Amberson", email: "aa@gmail.com", bio:"wassup", password:"aamerson", role: :standard)
        @u3 = User.create!(first: "Charlie", last: "Chaplin", email: "cc@gmail.com", bio:"hey there", password:"cchaplin", role: :standard)
        visit books_path
        click_on "Log In"
        fill_in 'Email', with: "cc@gmail.com"
        fill_in 'Password', with: "cchaplin"
        click_on "Log in"
    end

    describe "add friend" do
        it "expect a friend to be successfully added" do
            expect(page).to have_content("Signed in successfully.")
            click_on "Social"
            expect(page).to have_content("Add Some Friends")
            click_on "#{@u1.first}"
            expect(page).to have_content("Friend successfully added")
            click_on "Social"
            expect(page).to have_content("Allie Amberson")
        end

        it "expect the friend added to have notification with the senders name" do
            expect(page).to have_content("Signed in successfully.")
            click_on "Social"
            click_on "#{@u1.first}"
            find('#profile_click').click
            click_on "Log Out"
            click_on "Log In"
            fill_in 'Email', with: "aa@gmail.com"
            fill_in 'Password', with: "aamerson"
            click_on "Log in"
            visit user_notifications_path(@u1)
            expect(page).to have_content("Charlie Chaplin")

        end
    end
end