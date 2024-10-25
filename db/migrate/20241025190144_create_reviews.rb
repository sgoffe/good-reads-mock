class CreateReviews < ActiveRecord::Migration[7.2]
  def change
    create_table :reviews do |t|
      t.string :user
      t.string :book
      t.integer :rating
      t.text :description

      t.timestamps
    end
  end
end
