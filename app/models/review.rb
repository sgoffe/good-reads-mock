class Review < ApplicationRecord
  belongs_to :user
  belongs_to :book
  validates :book_id, :presence => true
  validates_associated :book
  validates :user_id, :presence => true
  validates_associated :user
  validates :user, presence: true
  validates :book, presence: true
  validates :rating, presence: true
  validates :description, presence: true

end
