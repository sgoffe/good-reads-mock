class CreateUsers < ActiveRecord::Migration[7.2]
  def change
    create_table :users do |t|
      t.string :first
      t.string :last
      t.string :email
      t.text :bio

      t.timestamps
    end
  end
end
