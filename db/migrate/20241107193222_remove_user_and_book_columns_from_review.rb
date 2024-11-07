class RemoveUserAndBookColumnsFromReview < ActiveRecord::Migration[7.2]
  def change
    remove_column :reviews, :user
    remove_column :reviews, :book
    
  end
end
