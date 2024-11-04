class UpdateBookModelTryTwo < ActiveRecord::Migration[7.2]
  def change
    create_table "books", force: :cascade do |t|
      t.string "title"
      t.string "author"
      t.integer "genre"
      t.integer "pages"
      t.text "description"
      t.string "publisher"
      t.date "publish_date"
      t.integer "isbn_13"
      t.string "language_written"
      t.datetime "created_at", null: false
      t.datetime "updated_at", null: false
    end
  end
end
