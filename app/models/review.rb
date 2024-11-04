class Review < ApplicationRecord
  validates :user, presence: true
  validates :book, presence: true
  validates :rating, presence: true
  validates :description, presence: true
end
