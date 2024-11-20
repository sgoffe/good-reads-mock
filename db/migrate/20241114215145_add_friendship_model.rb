class AddFriendshipModel < ActiveRecord::Migration[7.2]
  def change
    create_table :friendships do |t|
      t.integer :user1_id, null: false
      t.integer :user2_id, null: false
    end
  end
end
