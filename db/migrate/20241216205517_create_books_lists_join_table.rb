class CreateBooksListsJoinTable < ActiveRecord::Migration[8.0]
  def change
    create_join_table :books, :lists do |t|
      t.index [:book_id, :list_id]
      t.index [:list_id, :book_id]
    end
  end
end
