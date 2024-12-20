require 'rails_helper'

RSpec.describe "ListsController", type: :system do
    include Devise::Test::IntegrationHelpers
    before do
        driven_by(:rack_test)
    end

    before(:each) do
        @u1 = User.create!(first: "Allie", last: "Amberson", email: "aa@gmail.com", bio:"wassup", password:"aamerson", role: :standard)
        @b1 = FactoryBot.create(:book, img_url: nil)
        @b2 = FactoryBot.create(:book, img_url: "https://th.bing.com/th/id/OIP.caKIPkEzOmvoKgGoa-KXwgAAAA?w=135&h=206&c=7&r=0&o=5&dpr=2&pid=1.7")
        sign_in @u1
    end
    
    describe "New/create list" do
        it "expect a list to be successfully created" do
            visit profile_path
            expect(page).not_to have_content("Untitled List")
            click_on "New list"
            expect(page).to have_content("List created successfully")
            expect(page).to have_content("Untitled List")
        end
        it "list create sad path" do
            visit profile_path
            expect(page).not_to have_content("Untitled List")
            list_mock = instance_double(List, title: "Untitled List")
            allow(List).to receive(:new).with(title: "Untitled List").and_return(list_mock)
            expect(list_mock).to receive(:user=).and_return(@u1)
            expect(list_mock).to receive(:save).and_return(nil)
            click_on "New list"
            expect(page).not_to have_content("Untitled List")
            expect(page).to have_content("List could not be created")
        end
    end

    describe "Edit/update list" do
        it "expect a list to be successfully updated" do
            visit profile_path
            click_on "New list"
            expect(page).to have_content("Untitled List")
            click_on 'Edit list', match: :first
            fill_in 'Title', with: 'edit test'
            click_on 'Update List'
            expect(page.current_path).to eq(profile_path)
            expect(page).to have_content("List updated successfully")
            expect(page).to have_content("edit test")
        end
        
    end
    describe "destroying a review" do
        it 'deletes a review' do
            visit profile_path
            click_on "New list"
            expect(@u1.lists.count).to eq(2) 
            click_on 'Delete'
            expect(page).to have_content('List deleted successfully')
            expect(page).not_to have_content('Untitled List')
            expect(@u1.lists.count).to eq(1) 
        end
        
        
    
        describe 'handles failed delete' do
            it 'due to db error' do
                l = List.create!(user: @u1, title: "test list")
                allow_any_instance_of(List).to receive(:destroy).and_raise(StandardError)
            
                visit profile_path
                find(".list-item[data-title='test list']").click_on 'Delete'
                expect(page.current_path).to eq(profile_path)
                expect(page).to have_content('Error deleting list')
            end
            
            
    
            it 'due to invalid id' do
                l = List.create!(user: @u1, title: "test list")
                allow_any_instance_of(List).to receive(:destroy).and_raise(ActiveRecord::RecordNotFound)
            
                visit profile_path
                click_on 'Delete', match: :first
                expect(page.current_path).to eq(profile_path)
                expect(page).to have_content('List not found')
            end
            
        end
    end
end