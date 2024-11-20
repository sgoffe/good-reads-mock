FactoryBot.define do
  factory :book do
    title { 'Sirens of Titan' }
    author { 'Kurt Vonnegut' }
    genre { :science_fiction } # Using the enum key instead of integer
    pages { 275 }
    description { 'A science fiction novel about space, time, and human folly.' }
    publisher { 'Delacorte Press' }
    publish_date { '1961-03-10' }
    isbn_13 { 9780385333498 }
    language_written { 'English' }
  end
end
