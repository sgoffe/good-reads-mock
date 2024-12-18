require 'rails_helper'

RSpec.describe "UserController", type: :system do
    before do
        driven_by(:rack_test)
    end

    before(:each) do
        @u1 = User.create!(first: "Allie", last: "Amberson", email: "aa@gmail.com", bio:"wassup", password:"aamberson", role: :admin)
        @u2 = User.create!(first: "Brett", last: "Boyerton", email: "bb@gmail.com", bio:"howdy", password:"bboyerton", role: :standard)
        @u3 = User.create!(first: "Charlie", last: "Chaplin", email: "cc@gmail.com", bio:"hey there", password:"cchaplin", role: :standard)
    end

    describe "index method" do
        it "expect all users to be present in index" do
            visit users_path
            expect(page).to have_content("aa@gmail.com")
            expect(page).to have_content("Brett Boyerton")
            expect(page).to have_content("hey there")
        end
    end
    describe "edit/update methods" do
        it "successfully edits Brett" do
            visit user_path(@u2)
            click_on "Edit"
            fill_in "First", with: "Barry"
            click_on "Update User"
            expect(page).to have_content("Barry")
            expect(page).not_to have_content("Brett")
        end

        it "fails to update Brett" do
            visit user_path(@u2)
            click_on "Edit"
            fill_in "First", with: "Barry"
            expect(User).to receive(:find).and_return(@u1)
            expect(@u1).to receive(:update).and_return(nil)
            click_on "Update User"
            expect(page).to have_content("Edit User")
        end
    end
    describe "new/create methods" do 
        it "successfully creates Durk" do
            visit books_path
            click_on "Log In"
            click_on "Sign up here!"
            fill_in 'First', with: "Durk"
            fill_in 'Last', with: "Deacon"
            fill_in 'Email', with: "dd@gmail.com"
            fill_in 'Password', with: "123456"
            fill_in 'Password confirmation', with: "123456"
            click_on "Sign up"
            expect(User.all.count).to eq(4)
            expect(page).to have_selector("#profile_click")
            find('#profile_click').click
            expect(page).to have_current_path(profile_path)
            expect(page).to have_content("Durk Deacon")
        end

        it "fails to create Durk" do
            visit books_path
            click_on "Log In"
            click_on "Sign up here!"
            fill_in 'First', with: "Durk"
            click_on "Sign up"
            expect(page).to have_content("errors prohibited this user from being saved")
            expect(page).not_to have_selector("#profile_click")
        end
    end
    describe "destroy method" do
        it "successfully destroys Allie" do
            @u1.destroy
            @u2.destroy
            visit user_admin_path(@u3)
            expect(page).to have_content("Name: ")
            click_on "Delete User"
            expect(page).not_to have_content("Name: ")
        end
    end
    describe "profile method" do
        it "successfully shows Allie's profile" do
            visit books_path
            click_on "Log In"
            fill_in 'Email', with: "aa@gmail.com"
            fill_in 'Password', with: "aamberson"
            click_on "Log in"
            expect(page).to have_content("Signed in successfully.")
            expect(page).to have_selector("#profile_click")
            find('#profile_click').click
            expect(page).to have_current_path(profile_path)
            expect(page).to have_content("Bio: wassup")
        end
    end

    describe "log in and out" do
        it "successfully logs in and logs out a user" do
            visit books_path
            click_on "Log In"
            fill_in 'Email', with: "aa@gmail.com"
            fill_in 'Password', with: "aamberson"
            click_on "Log in"
            expect(page).to have_content("Signed in successfully.")
            expect(page).to have_selector("#profile_click")
            find('#profile_click').click
            expect(page).to have_current_path(profile_path)
            click_on "Log Out"
            expect(page).to have_content("Signed out successfully.")
        end
    end

end