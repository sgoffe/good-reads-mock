class GoogleBooksService
  include HTTParty
  base_uri 'https://www.googleapis.com/books/v1'

  def initialize(api_key)
    @api_key = api_key
  end

  def search_books(query)
    self.class.get('/volumes', query: { q: query, key: @api_key })
  end

  def get_book_details(volume_id)
    self.class.get("/volumes/#{volume_id}", query: { key: @api_key })
  end
end
