class AddReadToNotifications < ActiveRecord::Migration[8.0]
  def change
    unless column_exists?(:notifications, :read)
      add_column :notifications, :read, :boolean, default: false, null: false
    end
  end
end
