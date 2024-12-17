FactoryBot.define do
  factory :notification do
    association :sender, factory: :user
    association :receiver, factory: :user
    association :notifiable, factory: :book 
    
    title  { "<strong>#{sender.first} #{sender.last}</strong> recommended <strong>#{notifiable.title}</strong> to you!" }
    message { "This is a message" }
    notifiable_type { 'recommendation' }
  end
end