class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable
  has_many :reviews
  has_many :books, through: :reviews
  
  validates :first, presence: true
  validates :last, presence: true
  validates :email, presence: true


  enum :role, %i[admin standard]
end
