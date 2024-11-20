class NotificationsController < ApplicationController
  before_action :authenticate_user!

  def index
    if current_user.id != params[:user_id].to_i
      redirect_to root_path, alert: "You are not authorized to view this page."
    else
      @notifications = current_user.notifications.order(created_at: :desc)
    end
  end

  def recommend
    @book = Book.find(params[:id])
    @notification = Notification.new
  end

  def create_recommendation
    @notification = Notification.new(
      sender: current_user,
      receiver: User.find(notification_params[:receiver_id]),
      title: "<strong>#{current_user.first} #{current_user.last}</strong> recommended <strong>#{Book.find(notification_params[:book_id]).title}</strong> to you!",
      message: notification_params[:message],
      notification_type: 'recommendation',
      notifiable: Book.find(notification_params[:book_id]) 
    )

    if @notification.save
      redirect_to book_path(notification_params[:book_id]), notice: "Recommendation sent!"
    else
      redirect_to book_path(notification_params[:book_id]), alert: "There was an error sending the recommendation."
    end
  end

private
  def notification_params
    params.require(:notification).permit(:receiver_id, :book_id, :message)
  end
end
