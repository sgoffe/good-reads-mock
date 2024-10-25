class Book < ApplicationRecord
  enum :genre, %i[historical_fiction fiction horror romance comedy thriller young_adult science_fiction mystery nonfiction]
  
end
