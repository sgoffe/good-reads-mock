class Book < ApplicationRecord
  has_many :reviews
  has_many :users, through: :reviews
  
  # enum :genre, %i[historical_fiction fiction horror romance comedy thriller young_adult science_fiction mystery nonfiction]

  # has_many_attached :images do |attachable|
  #   attachable.variant :thumb, resize_to_limit: [ 80, 80 ]
  #   attachable.variant :medium, resize_to_fill: [ 400, 400 ]
  # end

  # validates :title, :presence => true
  # validates :author, :presence => true
  # validates :genre, :presence => true
  # validates :pages, :presence => true, numericality: {greater_than_or_equal_to: 0}
  # validates :description, :presence => true
  # validates :publisher, :presence => true
  # validates :publish_date, :presence => true
  # validates :isbn_13, :presence => true 
  # validates :language_written, :presence => true
  validates :title, :author, :genre, :pages, :description, :publisher, :publish_date, :isbn_13, :language_written, presence: true
  validates :pages, numericality: { greater_than_or_equal_to: 0 }

  
  def self.pages_less_than_or_eq_to?(pagecount)
    Book.where("pages <= ?", pagecount.to_i).order(:title)
  end

  def self.by_search_string(substr)
    words = substr.split.map { |word| "%#{word}%" }
    Book.where(substr.split.map { |word| "(title LIKE ? OR author LIKE ? OR description LIKE ?)" }.join(" AND "), *words.flat_map { |word| [word, word, word] })
  end

  def self.with_average_rating(value)
    Book.joins(:reviews).group("books.id").having("AVG(rating) >= ?", value)
  end

  def self.rating
    Book.joins(:reviews).group("books.id")
  end

  def self.in_genre(genre)
    Book.where(genre: genre)
  end
end