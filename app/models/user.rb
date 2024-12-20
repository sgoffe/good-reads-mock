class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable
  has_many :reviews, dependent: :destroy
  has_many :books, through: :reviews
  has_many :sent_notifications, class_name: 'Notification', foreign_key: 'sender_id', dependent: :destroy
  has_many :received_notifications, class_name: 'Notification', foreign_key: 'receiver_id', dependent: :destroy
  has_many :friendships, dependent: :destroy
  has_many :friends, through: :friendships
  has_many :lists, dependent: :destroy
  has_many :books, through: :lists
  
  validates :first, presence: true
  validates :last, presence: true
  validates :email, presence: true

  enum :role, %i[admin standard]

  def notifications
    received_notifications
  end

  def num_unread_messages
    self.notifications.unread.count
  end
end
