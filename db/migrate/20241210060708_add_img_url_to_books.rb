class AddImgUrlToBooks < ActiveRecord::Migration[8.0]
  def change
    add_column :books, :img_url, :string
  end
end
