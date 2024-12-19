require 'rails_helper'

RSpec.describe "FriendController", type: :system do
    before do
        driven_by(:rack_test)
    end

    before(:each) do
        @u1 = User.create!(first: "Allie", last: "Amberson", email: "aa@gmail.com", bio:"wassup", password:"aamerson", role: :admin)
        @u2 = User.create!(first: "Brett", last: "Boyerton", email: "bb@gmail.com", bio:"howdy", password:"bboyerton", role: :standard)
        @u3 = User.create!(first: "Charlie", last: "Chaplin", email: "cc@gmail.com", bio:"hey there", password:"cchaplin", role: :standard)
        @u4 = User.create!(first: "ZEEK", last: "ZepperHead", email: "cowboyRADEER@gmail.com", bio:"ughgGHGHH", password:"ZEEKboi", role: :standard)
    end

    describe "filter by first" do
        it "expect users to correctly be filtered by first name" do
            visit books_path
            click_on "Log In"
            fill_in 'Email', with: "cowboyRADEER@gmail.com"
            fill_in 'Password', with: "ZEEKboi"
            click_on "Log in"
            visit friendships_find_path
            fill_in "first_query", with: 'All'
            click_on "Filter Users"
            expect(page).to have_content("Allie")
            expect(page).not_to have_content("Brett")
            expect(page).not_to have_content("Charlie")
        end
    end

    describe "filter by last" do
        it "expect users to correctly be filtered by last name" do
            visit books_path
            click_on "Log In"
            fill_in 'Email', with: "cowboyRADEER@gmail.com"
            fill_in 'Password', with: "ZEEKboi"
            click_on "Log in"
            visit friendships_find_path
            fill_in "last_query", with: 'O'
            click_on "Filter Users"
            expect(page).to have_content("Allie")
            expect(page).to have_content("Brett")
            expect(page).not_to have_content("Charlie")
        end
    end

    describe "filter by email" do
        it "expect users to correctly be filtered by email" do
            visit books_path
            click_on "Log In"
            fill_in 'Email', with: "cowboyRADEER@gmail.com"
            fill_in 'Password', with: "ZEEKboi"
            click_on "Log in"
            visit friendships_find_path
            fill_in "email_query", with: 'bb'
            click_on "Filter Users"
            expect(page).not_to have_content("Allie")
            expect(page).to have_content("Brett")
            expect(page).not_to have_content("Charlie")
        end
    end

end