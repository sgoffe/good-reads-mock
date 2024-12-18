class DropBooksTable < ActiveRecord::Migration[8.0]
  def change
    drop_table :books, if_exists: true
  end
end
