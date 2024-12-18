class List < ApplicationRecord
  belongs_to :user
  has_and_belongs_to_many :books
  validates :user_id, :presence => true
  validates_associated :user
  validates :title, :presence => true
end
