class RenameDescriptionToReviewText < ActiveRecord::Migration[8.0]
  def change
    rename_column :reviews, :description, :review_text
  end
end
