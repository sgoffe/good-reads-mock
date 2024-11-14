require 'rails_helper'
require 'simplecov'
SimpleCov.start 'rails'

RSpec.describe "UserController", type: :system do
    before do
        driven_by(:rack_test)
    end

    before(:each) do
        @u1 = User.create!(first: "Allie", last: "Amberson", email: "aa@gmail.com", bio:"wassup", role: admin)
        @u2 = User.create!(first: "Brett", last: "Boyerton", email: "bb@gmail.com", bio:"howdy", role: standard)
        @u3 = User.create!(first: "Charlie", last: "Chaplin", email: "cc@gmail.com", bio:"hey there", role: standard)
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
    end
    describe "new/create methods" do 
        it "successfully creates Durk" do
            visit users_path
            click_on "Create new user"
            fill_in 'First', with: "Durk"
            fill_in 'Last', with: "Deacon"
            fill_in 'Email', with: "dd@gmail.com"
            fill_in 'Bio', with: "yuhh"
            click_on "Create User"
            expect(page).to have_content("Durk Deacon")
            expect(page).to have_content("dd@gmail.com")
            expect(User.all.count).to eq(4)
        end

        it "fails to create Durk" do
            visit users_path
            click_on "Create new user"
            fill_in 'First', with: "Durk"
            click_on "Create User"
            expect(page).to have_content("Unable to create user. Please try again")
            expect(page).not_to have_content("Durk")
        end
    end
    describe "destroy method" do
        it "successfully destroys Allie" do
            visit user_path(@u1)
            click_on "Delete"
            expect(page).not_to have_content("Allie")
            expect(page).not_to have_content("aa@gmail.com")
            expect(page).to have_content("Brett")
            expect(page).to have_content("Charlie")
        end
    end
    describe "show method" do
        it "successfully shows Allie" do
            visit user_path(@u2)
            click_on "Delete"
            visit user_path(@u3)
            click_on "Delete"
            click_on "More about this user"
            expect(page).to have_content("wassup")
            expect(page).to have_content("Back to Index")
        end
    end

end