require 'rails_helper'

RSpec.describe "AddFriend", type: :system do
    before do
        driven_by(:rack_test)
    end

    before(:each) do
        @u1 = User.create!(first: "Allie", last: "Amberson", email: "aa@gmail.com", bio:"wassup", password:"aamerson", role: :standard)
        @u3 = User.create!(first: "Charlie", last: "Chaplin", email: "cc@gmail.com", bio:"hey there", password:"cchaplin", role: :standard)
    end

    describe "add friend" do
        it "expect a friend to be successfully added" do
            visit books_path
            click_on "Log In"
            fill_in 'Email', with: "cc@gmail.com"
            fill_in 'Password', with: "cchaplin"
            click_on "Log in"
            expect(page).to have_content("cc@gmail.com")
            expect(page).to have_content("Log Out")
            click_on "Social"
            expect(page).to have_content("This user has no friends")
            click_on "Add friend"
            expect(page).to have_content("Friend successfully added")
            click_on "Social"
            expect(page).to have_content("Friend: Allie Amberson")
        end
    end
end