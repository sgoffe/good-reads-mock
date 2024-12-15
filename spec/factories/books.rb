FactoryBot.define do
  factory :book do
    sequence(:title) { |n| "Sample Title #{n}" }
    sequence(:author) { |n| "Sample Author #{n}" }
    genre { 'Fiction' }
    pages { 200 }
    description { 'A sample description.' }
    publisher { 'Sample Publisher' }
    publish_date { '2023-01-01' }
    sequence(:isbn_13) { |n| n.to_s.rjust(13, '0') }
    language_written { 'English' }
    img_url { 'https://th.bing.com/th/id/OIP.caKIPkEzOmvoKgGoa-KXwgAAAA?w=135&h=206&c=7&r=0&o=5&dpr=2&pid=1.7' }
  end
end
