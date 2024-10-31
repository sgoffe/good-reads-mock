class Review < ApplicationRecord
	belongs_to :user
  belongs_to :book

	validates :description, presence: true
	validates :rating, presence: true
end
