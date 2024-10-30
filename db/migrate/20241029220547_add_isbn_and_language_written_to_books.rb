class AddIsbnAndLanguageWrittenToBooks < ActiveRecord::Migration[7.2]
  def change
    add_column :books, :isbn, :integer
    add_column :books, :language_written, :string
  end
end
