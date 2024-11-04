class ChangeBooksSchema < ActiveRecord::Migration[7.2]
  def change
    change_column :books, :publish_date, :date
    change_column :books, :isbn_13, :string
  end
end
