class CreateNotifications < ActiveRecord::Migration[8.0]
  def change
    create_table :notifications do |t|
      t.references :sender, null: false, foreign_key: { to_table: :users }
      t.references :receiver, null: false, foreign_key: { to_table: :users }
      t.string :title
      t.text :message
      t.string :notification_type
      t.references :notifiable, polymorphic: true, null: false

      t.timestamps
    end
  end
end
