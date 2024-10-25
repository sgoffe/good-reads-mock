class CreateBooks < ActiveRecord::Migration[7.2]
  def change
    create_table :books do |t|
      t.string :title
      t.string :author
      t.integer :genre
      t.integer :pages
      t.text :description
      t.string :publisher
      t.time :publish_date

      t.timestamps
    end
  end
end
