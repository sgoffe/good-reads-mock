class AddLikesToReviews < ActiveRecord::Migration[7.2]
  def change
    add_column :reviews, :likes, :integer
  end
end
