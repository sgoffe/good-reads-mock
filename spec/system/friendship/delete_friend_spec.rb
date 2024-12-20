require 'rails_helper'

RSpec.describe "DeleteFriend", type: :system do
    before do
        driven_by(:rack_test)
    end

    before(:each) do
        @u1 = User.create!(first: "Allie", last: "Amberson", email: "aa@gmail.com", bio:"wassup", password:"aamerson", role: :standard)
        @u3 = User.create!(first: "Charlie", last: "Chaplin", email: "cc@gmail.com", bio:"hey there", password:"cchaplin", role: :standard)
    end

    describe "delete friend" do
        it "expect a friend to be successfully deleted" do
            visit books_path
            click_on "Log In"
            fill_in 'Email', with: "cc@gmail.com"
            fill_in 'Password', with: "cchaplin"
            click_on "Log in"
            expect(page).to have_content("Signed in successfully.")
            click_on "Social"
            expect(page).to have_content("Add Some Friends")
            click_on "#{@u1.first}"
            expect(page).to have_content("Friend successfully added")
            click_on "Social"
            expect(page).to have_content("Friend: Allie Amberson")
            click_on "#{@u1.first}"
            expect(page).to have_content("Friend removed successfully")
            click_on "Social"
            expect(page).to have_content("Add Some Friends")
        end
    end
end