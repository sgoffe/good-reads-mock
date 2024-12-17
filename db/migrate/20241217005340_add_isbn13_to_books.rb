class AddIsbn13ToBooks < ActiveRecord::Migration[8.0]
  def change
    add_column :books, :isbn_13, :string
  end
end
