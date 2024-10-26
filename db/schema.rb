# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[7.2].define(version: 2024_10_25_190144) do
  create_table "books", force: :cascade do |t|
    t.string "title"
    t.string "author"
    t.integer "genre"
    t.integer "pages"
    t.text "description"
    t.string "publisher"
    t.time "publish_date"
    t.integer "isbn_13"
    t.string "language_written"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "reviews", force: :cascade do |t|
    t.string "user"
    t.string "book"
    t.integer "rating"
    t.text "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "users", force: :cascade do |t|
    t.string "first"
    t.string "last"
    t.string "email"
    t.text "bio"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end
end
