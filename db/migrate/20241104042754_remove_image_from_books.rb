class RemoveImageFromBooks < ActiveRecord::Migration[7.2]
  def change
    remove_column :books, :image, :string
  end
end
