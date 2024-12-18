require 'rails_helper'

RSpec.describe "CreateList", type: :system do
    before do
        driven_by(:rack_test)
    end

    before(:each) do
        @u1 = User.create!(first: "Allie", last: "Amberson", email: "aa@gmail.com", bio:"wassup", password:"aamerson", role: :standard)
        @b1 = FactoryBot.create(:book, img_url: nil)
        @b2 = FactoryBot.create(:book, img_url: "https://th.bing.com/th/id/OIP.caKIPkEzOmvoKgGoa-KXwgAAAA?w=135&h=206&c=7&r=0&o=5&dpr=2&pid=1.7")
    end
    
    describe "create list" do
        it "expect a list to be successfully created" do
            visit books_path
            click_on "Log In"
            fill_in 'Email', with: "aa@gmail.com"
            fill_in 'Password', with: "aamerson"
            click_on "Log in"
            expect(page).to have_content("Signed in successfully.")
            visit profile_path
            expect(page).not_to have_content("Untitled List")
            click_on "New list"
            expect(page).to have_content("List created successfully")
            expect(page).to have_content("Untitled List")
        end
        it "list create sad path" do
            visit books_path
            click_on "Log In"
            fill_in 'Email', with: "aa@gmail.com"
            fill_in 'Password', with: "aamerson"
            click_on "Log in"
            expect(page).to have_content("Signed in successfully.")
            visit profile_path
            expect(page).not_to have_content("Untitled List")
            expect(List).to receive(:new).and_return(nil)
            expect(page).not_to have_content("Untitled List")
            expect(page).to have_content("List could not be created.")
        end
    end
end