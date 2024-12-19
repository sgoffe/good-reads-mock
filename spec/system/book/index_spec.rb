require 'rails_helper'
require 'simplecov'

describe "Book Index" do 
  before(:each) do
    @u1 = User.create!(first: "Allie", last: "Amberson", 
              email: "aa@gmail.com", bio:"wassup", 
              password:"aamerson", role: :admin)
    @b1 = FactoryBot.create(:book, genre: "nonfiction")
    # @b1 = Book.create!(title: "a_test1", author: "test",
    #             genre: "nonfiction", 
    #             pages: 100, description: "test",
    #             publisher: "test",
    #             publish_date: Date.new(2002, 2, 2), isbn_13: 1111111111111, language_written: "test")
    @b2 = FactoryBot.create(:book, genre: "fiction")
    # @b2 = Book.create!(title: "b_test2", author: "test",
    #             genre: "fiction", 
    #             pages: 200, description: "test",
    #             publisher: "test",
    #             publish_date: Date.new(2002, 2, 2), isbn_13: 2222222222222, language_written: "test")
    @b3 = FactoryBot.create(:book, genre: "fiction")
    # @b3 = Book.create!(title: "c_test3", author: "test",
    #             genre: "fiction",  
    #             pages: 300, description: "test",
    #             publisher: "test",
    #             publish_date: Date.new(2002, 2, 2), isbn_13: 3333333333333, language_written: "test")
    @r2 = Review.create!(user: @u1, book: @b1, review_text: 'second', rating: 4)
    @r3 = Review.create!(user: @u1, book: @b2, review_text: 'third', rating: 3)
  end

  it "should allow the user to search by filling in query" do
    visit books_path
    
    within("#index-search-form") do
      fill_in 'query', with: @b2.title
      click_button 'Filter Books'
    end

    expect(page).to have_content(@b2.title)
    expect(page).not_to have_content(@b1.title)
    expect(page).not_to have_content(@b3.title)
  end

  it "should filter by average review" do
    visit books_path

    fill_in 'rating', with: @r2.rating
    click_button 'Filter Books'
    expect(page).to have_content(@b1.title)
    expect(page).not_to have_content(@b3.title)
    expect(page).not_to have_content(@b2.title)
    
    fill_in 'rating', with: @r3.rating
    click_button 'Filter Books'
    expect(page).to have_content(@b2.title)
    expect(page).to have_content(@b1.title)
    expect(page).not_to have_content(@b3.title)
  end

  it "should sort by rating" do
    visit books_path
    select 'Rating - Lowest to Highest', from: 'sort'
    click_button 'Filter Books'
    
    expect(page).to have_content(@b1.title)
    expect(page).to have_content(@b2.title)
  end

  it "should filter by genre" do
    visit books_path
    fill_in 'genre', with: 'fiction'
    click_button 'Filter Books'
    
    expect(page).to have_content(@b3.title)
    expect(page).to have_content(@b2.title)
    expect(page).not_to have_content(@b1.title)
  end
end

RSpec.describe 'Books Index Pagination', type: :request do
  before(:each) do
    User.destroy_all
    Review.destroy_all
    Book.destroy_all
    FactoryBot.reload
  end

  let!(:books) { create_list(:book, 25) }

  describe 'GET /books?page=X' do
    context 'when on the first page' do
      it 'displays the first set of books' do
        get books_path, params: { page: 1 }
        expect(response).to have_http_status(:ok)
        expect(assigns(:books).count).to eq(10)
        expect(assigns(:books).map(&:id)).to match_array(books.sort_by(&:title).first(10).map(&:id))
      end

      it 'does not have a previous page' do
        get books_path, params: { page: 1 }
        expect(assigns(:books).prev_page).to be_nil
      end
    end

    context 'when on a middle page' do
      it 'displays the correct set of books' do
        get books_path, params: { page: 2 }
        expect(response).to have_http_status(:ok)
        expect(assigns(:books).count).to eq(10)
        expect(assigns(:books).map(&:id)).to match_array(books.sort_by(&:title)[10...20].map(&:id))
      end

      it 'has both a previous and next page' do
        get books_path, params: { page: 2 }
        expect(assigns(:books).prev_page).to eq(1)
        expect(assigns(:books).next_page).to eq(3)
      end
    end

    context 'when on the last page' do
      it 'displays the remaining books' do
        get books_path, params: { page: 3 }
        expect(response).to have_http_status(:ok)
        expect(assigns(:books).count).to eq(5)
        expect(assigns(:books).map(&:id)).to match_array(books.sort_by(&:title).last(5).map(&:id))
      end

      it 'does not have a next page' do
        get books_path, params: { page: 3 }
        expect(assigns(:books).next_page).to be_nil
      end
    end

    context 'when page parameter is out of range' do
      it 'returns an empty result for too high a page number' do
        get books_path, params: { page: 4 }
        expect(response).to have_http_status(:ok)
        expect(assigns(:books)).to be_empty
      end

      it 'defaults to page 1 when page is not provided' do
        get books_path
        expect(response).to have_http_status(:ok)
        expect(assigns(:books).count).to eq(10)
        expect(assigns(:books).map(&:id)).to match_array(books.sort_by(&:title).first(10).map(&:id))
      end
    end
  end
end
