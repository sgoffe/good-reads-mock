class AddRatingToBooks < ActiveRecord::Migration[8.0]
  def change
    add_column :books, :rating, :decimal
  end
end
