class Book < ApplicationRecord
  has_many :reviews, dependent: :destroy

  enum :genre, %i[historical_fiction fiction horror romance comedy thriller young_adult science_fiction mystery nonfiction]
  
  def release_date 
    publish_date.strftime("%B %e, %Y")
  end
end
