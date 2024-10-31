class ChangePublishDateToDateInBooks < ActiveRecord::Migration[7.2]
  def change
    change_column :books, :publish_date, :date
  end
end
