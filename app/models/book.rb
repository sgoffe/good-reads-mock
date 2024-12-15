class Book < ApplicationRecord
  has_many :reviews
  has_many :users, through: :reviews
  
  has_one_attached :image

  validates :title, :author, :genre, :pages, :description, :publisher, :publish_date, :isbn_13, :language_written, presence: true
  validates :pages, numericality: { greater_than_or_equal_to: 0, only_integer: true }
  validates :isbn_13, presence: true, length: { is: 13 }, format: { with: /\A\d{13}\z/, message: "must be exactly 13 digits" }
  validates :isbn_13, uniqueness: true, allow_blank: true
  validate :publish_date_must_be_in_the_past_or_today

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
    # Book.joins(:reviews).group("books.id")
    Book.joins(:reviews).distinct.group("books.id")
  end

  def self.in_genre(genre)
    Book.where(genre: genre)
  end

  private
  
  def publish_date_must_be_in_the_past_or_today
    if publish_date.present? && publish_date > Date.today
      errors.add(:publish_date, "can't be in the future")
    end
  end

end