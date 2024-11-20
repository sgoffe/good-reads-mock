class ChangeFriendshipTable < ActiveRecord::Migration[8.0]
  def change
    remove_column :friendships, :user1_id
    remove_column :friendships, :user2_id
    add_column :friendships, :user_id, :integer
    add_column :friendships, :friend_id, :integer
  end


end
