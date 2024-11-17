class Notification < ApplicationRecord
  include Rails.application.routes.url_helpers

  belongs_to :sender, class_name: 'User'
  belongs_to :receiver, class_name: 'User'
  belongs_to :notifiable, polymorphic: true

  def formatted_title
    if notifiable_type == 'Book'
      "<strong>#{sender.first} #{sender.last}</strong> recommended <strong>#{notifiable.title}</strong> to you"
    elsif notifiable_type == 'FriendRequest'
      "#{sender.first} #{sender.last} sent you a friend request"
    end
  end

  def notification_url
    if notifiable_type == 'Book'
      book_path(notifiable_id) 
    elsif notifiable_type == 'FriendRequest'
      user_path(notifiable_id) 
    end
  end

  def formatted_timestamp
    created_at.in_time_zone("Eastern Time (US & Canada)").strftime("%B %d, %Y - %I:%M %p")
  end  
end
