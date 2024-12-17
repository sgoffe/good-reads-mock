require 'rails_helper'

RSpec.describe "UserController", type: :system do
    before do
        driven_by(:rack_test)
    end

    before(:each) do
        @u1 = User.create!(first: "Allie", last: "Amberson", email: "aa@gmail.com", bio:"wassup", password:"aamerson", role: :admin)
        @u2 = User.create!(first: "Brett", last: "Boyerton", email: "bb@gmail.com", bio:"howdy", password:"bboyerton", role: :standard)
        @u3 = User.create!(first: "Charlie", last: "Chaplin", email: "cc@gmail.com", bio:"hey there", password:"cchaplin", role: :standard)
        @b1 = Book.create!(title: "test", author: "test",
		genre: :fiction,
		pages: 100, description: "test",
		publisher: "test",
		publish_date: Date.new(1222, 2, 2), isbn_13: 1111111111111, language_written: "test")
        @r1 = Review.create!(user: @u1, book: @b1, rating: 4, review_text: "Awesome book")
    end

    describe "filter by first" do
        it "expect users to correctly be filtered by first name" do
            visit user_admin_path(@u1)
            fill_in "first_query", with: 'All'
            click_on "Filter Users"
            expect(page).to have_content("Name: Allie")
            expect(page).not_to have_content("Name: Brett")
            expect(page).not_to have_content("Name: Charlie")
        end
    end

    describe "filter by last" do
        it "expect users to correctly be filtered by last name" do
            visit user_admin_path(@u1)
            fill_in "last_query", with: 'O'
            click_on "Filter Users"
            expect(page).to have_content("Name: Allie")
            expect(page).to have_content("Name: Brett")
            expect(page).not_to have_content("Name: Charlie")
        end
    end

    describe "filter by email" do
        it "expect users to correctly be filtered by email" do
            visit user_admin_path(@u1)
            fill_in "email_query", with: 'bb'
            click_on "Filter Users"
            expect(page).not_to have_content("Name: Allie")
            expect(page).to have_content("Name: Brett")
            expect(page).not_to have_content("Name: Charlie")
        end
    end

    describe "remove review happy" do
        it "expect review deletion to be successful" do
            @u2.destroy
            @u3.destroy
            visit user_admin_path(@u1)
            click_on "View Reviews"
            expect(page).to have_content("Rating: 4")
            expect(page).to have_content("Content: Awesome book")
            click_on "Delete review"
            visit user_admin_path(@u1)
            click_on "View Reviews"
            expect(page).not_to have_content("Rating: 4")
            expect(page).not_to have_content("Content: Awesome book")
        end
    end
end
