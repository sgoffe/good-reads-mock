class Book < ApplicationRecord
  enum :genre, %i[historical_fiction fiction horror romance comedy thriller young_adult science_fiction mystery nonfiction]

  has_many_attached :images do |attachable|
    attachable.variant :thumb, resize_to_limit: [ 80, 80 ]
    attachable.variant :medium, resize_to_fill: [ 400, 400 ]
  end

  def self.pages_less_than_or_eq_to?(pagecount)
    self.where("pages <=  ?", pagecount).order(:title)
  end

  def self.by_search_string(substr)
    self.where("title LIKE ?", "%#{substr}%").or(self.where("author LIKE ?", "%#{substr}%")).or(self.where("description LIKE ?", "%#{substr}%"))
  end
end
