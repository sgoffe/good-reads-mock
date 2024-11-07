class Review < ApplicationRecord
  belongs_to :user
  belongs_to :book
  
  validates :user, presence: true
  validates :book, presence: true
  validates :rating, presence: true
  validates :description, presence: true
end
