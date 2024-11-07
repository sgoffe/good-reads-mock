class User < ApplicationRecord
    has_many :reviews
    has_many :books, through: :reviews
    
    validates :first, presence: true
    validates :last, presence: true
    validates :email, presence: true
    validates :bio, presence: true
end
