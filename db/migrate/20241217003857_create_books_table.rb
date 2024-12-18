class CreateBooksTable < ActiveRecord::Migration[6.1]
  def change
    create_table :books do |t|
      t.string :google_books_id, null: false
      t.string :title, null: false
      t.string :author
      t.string :img_url
      t.string :genre
      t.date :publish_date
      t.text :description

      t.timestamps
    end

    # Add a unique index for google_books_id
    add_index :books, :google_books_id, unique: true
  end
end
