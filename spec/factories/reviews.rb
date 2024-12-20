FactoryBot.define do
  factory :review do
    association :book_id, factory: :book
    association :user_id, factory: :user
    
    rating  { 4 }
    review_text { "This is a review" }
  end
end