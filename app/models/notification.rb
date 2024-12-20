class Notification < ApplicationRecord
  include Rails.application.routes.url_helpers

  scope :unread, -> { where(read: false) }

  belongs_to :sender, class_name: 'User', dependent: :destroy
  belongs_to :receiver, class_name: 'User', dependent: :destroy
  belongs_to :notifiable, polymorphic: true
  validates :receiver_id, :presence => true
  validates :sender, :presence => true
  validates :title, :presence => true
  validates :notifiable_id, :presence => true
  validates :notifiable_type, :presence => true
  validate :sender_and_receiver_are_different 

  def formatted_title
    if notifiable_type == 'Book'
      "<strong>#{sender.first} #{sender.last}</strong> recommended <strong>#{notifiable.title}</strong> to you"
    elsif notifiable_type == 'User'
      "<strong>#{sender.first} #{sender.last}</strong> added you as a friend!"
    end
  end

  def notification_url
    if notifiable_type == 'Book'
      book_path(notifiable_id) 
    elsif notifiable_type == 'User'
      user_path(notifiable_id) 
    end
  end

  def formatted_timestamp
    created_at.in_time_zone("Eastern Time (US & Canada)").strftime("%B %d, %Y - %I:%M %p")
  end  

private
  def sender_and_receiver_are_different
    if sender == receiver
      errors.add(:receiver, "can't be the same as sender")
    end
  end
end
