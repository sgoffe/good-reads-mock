require 'rails_helper'
require 'simplecov'

describe "Book Index" do 
  before(:each) do
    @u1 = User.create!(first: "Allie", last: "Amberson", 
              email: "aa@gmail.com", bio:"wassup", 
              password:"aamerson", role: :admin)
    @b1 = Book.create!(title: "a_test1", author: "test",
                genre: "nonfiction", 
                pages: 100, description: "test",
                publisher: "test",
                publish_date: Date.new(2222, 2, 2), isbn_13: 1111111111111, language_written: "test")
    @b2 = Book.create!(title: "b_test2", author: "test",
                genre: "fiction", 
                pages: 200, description: "test",
                publisher: "test",
                publish_date: Date.new(2222, 2, 2), isbn_13: 2222222222222, language_written: "test")
    @b3 = Book.create!(title: "c_test3", author: "test",
                genre: "fiction", 
                pages: 300, description: "test",
                publisher: "test",
                publish_date: Date.new(2222, 2, 2), isbn_13: 3333333333333, language_written: "test")
    @r2 = Review.create!(user: @u1, book: @b1, review_text: 'second', rating: 4)
    @r3 = Review.create!(user: @u1, book: @b2, review_text: 'third', rating: 3)
  end

  it "should allow the user to search by filling in query" do
    visit books_path
    fill_in 'query', with: 'b_test2'
    click_button 'Filter Books'
    
    expect(page).to have_content('b_test2')
    expect(page).not_to have_content('a_test1')
    expect(page).not_to have_content('c_test3')
  end

  it "should filter by average review" do
    visit books_path
    
    fill_in 'rating', with: '4'
    click_button 'Filter Books'
    expect(page).to have_content('a_test1')
    expect(page).not_to have_content('c_test3')
    expect(page).not_to have_content('b_test2')
    
    fill_in 'rating', with: '3'
    click_button 'Filter Books'
    expect(page).to have_content('b_test2')
    expect(page).to have_content('a_test1')
    expect(page).not_to have_content('c_test3')
  end

  it "should sort by rating" do
    visit books_path
    select 'Rating - Lowest to Highest', from: 'sort'
    click_button 'Filter Books'
    
    expect(page).to have_content('a_test1')
    expect(page).to have_content('b_test2')
    expect(page).not_to have_content('c_test3')
  end

  it "should filter by genre" do
    visit books_path
    fill_in 'genre', with: 'fiction'
    click_button 'Filter Books'
    
    expect(page).to have_content('c_test3')
    expect(page).to have_content('b_test2')
    expect(page).not_to have_content('a_test1')
  end
end