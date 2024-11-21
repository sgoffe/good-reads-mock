class Review < ApplicationRecord
  belongs_to :user
  belongs_to :book
  validates :book_id, :presence => true
  validates_associated :book
  validates :user_id, :presence => true
  validates_associated :user
  validates :rating, presence: true
  validates :review_text, presence: true

end
