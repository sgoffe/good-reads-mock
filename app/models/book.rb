class Book < ApplicationRecord
  # enum :genre, %i[historical_fiction fiction horror romance comedy thriller young_adult science_fiction mystery nonfiction]
  enum :genre, %i[fiction nonfiction science history fantasy mystery biography]
  has_many_attached :images do |attachable|
    attachable.variant :thumb, resize_to_limit: [80, 80]
    attachable.variant :medium, resize_to_fill: [400, 400]
  end

  validates :title, presence: true
  validates :author, presence: true
  validates :genre, presence: true
  validates :pages, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :description, presence: true
  validates :publisher, presence: true
  validates :isbn_13, presence: true
  validates :language_written, presence: true

  def self.pages_less_than_or_eq_to?(pagecount)
    self.where("pages <=  ?", pagecount.to_i).order(:title)
  end

  def self.by_search_string(substr)
    self.where("title LIKE ?", "%#{substr}%").or(self.where("author LIKE ?", "%#{substr}%")).or(self.where("description LIKE ?", "%#{substr}%"))
  end

end
