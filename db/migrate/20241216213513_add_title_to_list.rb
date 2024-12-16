class AddTitleToList < ActiveRecord::Migration[8.0]
  def change
    add_column :lists, :title, :string
  end
end
