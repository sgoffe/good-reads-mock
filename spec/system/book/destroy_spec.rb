require 'rails_helper'
require 'webmock/rspec'

describe "destroy" do
  before(:each) do 
    WebMock.disable_net_connect!(allow_localhost: true)
    stub_request(:get, "https://th.bing.com/th/id/OIP.caKIPkEzOmvoKgGoa-KXwgAAAA?w=135&h=206&c=7&r=0&o=5&dpr=2&pid=1.7").
      to_return(status: 200, body: "", headers: {})
    
    @b1 = Book.create!(
      title: "a_test1", 
      author: "test",
      description: "test",
      genre: "nonfiction", 
      publisher: "test",
      publish_date: Date.new(2222, 2, 2), 
      language_written: "test",
      pages: 100, 
      isbn_13: 1111111111111, 
      img_url: "https://th.bing.com/th/id/OIP.caKIPkEzOmvoKgGoa-KXwgAAAA?w=135&h=206&c=7&r=0&o=5&dpr=2&pid=1.7"
    )
  end

  it "should destroy book" do
    visit book_path(@b1)
    accept_confirm do
      click_button 'Delete book (will need permissions)'
    end

    expect(page).to have_content('Book deleted successfully')
    expect(page).not_to have_content(@b1.title)
  end
end
