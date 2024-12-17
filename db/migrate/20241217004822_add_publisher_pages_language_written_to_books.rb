class AddPublisherPagesLanguageWrittenToBooks < ActiveRecord::Migration[8.0]
  def change
    add_column :books, :publisher, :string
    add_column :books, :pages, :integer
    add_column :books, :language_written, :string
  end
end
