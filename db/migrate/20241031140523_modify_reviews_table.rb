class ModifyReviewsTable < ActiveRecord::Migration[7.2]
  def change
    # Remove the existing user and book columns
    remove_column :reviews, :user, :string
    remove_column :reviews, :book, :string

    # Add user_id and book_id as foreign keys
    add_reference :reviews, :user, foreign_key: true
    add_reference :reviews, :book, foreign_key: true
  end
end
