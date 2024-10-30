# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end

b1 = Book.create!(title: 'Sula',
                author: 'Toni Morrison',
                genre: :historical_fiction,
                pages: 174,
                description: 'Sula and Nel are two young black girls: clever and poor. They grow up together sharing their secrets, dreams and happiness. Then Sula breaks free from their small-town community in the uplands of Ohio to roam the cities of America. When she returns ten years later much has changed. Including Nel, who now has a husband and three children. The friendship between the two women becomes strained and the whole town grows wary as Sula continues in her wayward, vagabond and uncompromising ways.',
                publisher: 'Plume',
                publish_date: Date.new(1973, 1, 1),
                isbn: 9780452283862,
                language_written: 'English')

b2 = Book.create!(title: 'Jailbird',
                author: 'Kurt Vonnegut Jr.',
                genre: :fiction,
                pages: 288,
                description: 'Jailbird takes us into a fractured and comic, pure Vonnegut world of high crimes and misdemeanors in government—and in the heart. This wry tale follows bumbling bureaucrat Walter F. Starbuck from Harvard to the Nixon White House to the penitentiary as Watergate’s least known co-conspirator. But the humor turns dark when Vonnegut shines his spotlight on the cold hearts and calculated greed of the mighty, giving a razor-sharp edge to an unforgettable portrait of power and politics in our times.',
                publisher: 'Dell',
                publish_date: Date.new(1979, 1, 1),
                isbn: 9780440154471,
                language_written: 'English')

b3 = Book.create!(title: 'Angela\'s Ashes',
                author: 'Frank McCourt',
                genre: :nonfiction,
                pages: 452,
                description: 'So begins the Pulitzer Prize winning memoir of Frank McCourt, born in Depression-era Brooklyn to recent Irish immigrants and raised in the slums of Limerick, Ireland. Frank\'s mother, Angela, has no money to feed the children since Frank\'s father, Malachy, rarely works, and when he does he drinks his wages. Yet Malachy—exasperating, irresponsible and beguiling—does nurture in Frank an appetite for the one thing he can provide: a story. Frank lives for his father\'s tales of Cuchulain, who saved Ireland, and of the Angel on the Seventh Step, who brings his mother babies.',
                publisher: 'Harper Perennial',
                publish_date: Date.new(1996, 9, 5),
                isbn: 9780007205233,
                language_written: 'English')

r1 = Review.create!(user: 'Sophia Goffe',
                book: 'Sula',
                rating: 5,
                description: 'currently my favorite book',
                likes: 5)

r2 = Review.create!(user: 'Meghan Subak',
                book: 'the cartographers',
                rating: 4,
                description: 'Maps Fantasy Library',
                likes: 10)

r3 = Review.create!(user: 'Mickey Mouse',
                book: 'Crime and Punishment',
                rating: 3,
                description: 'disturbed', 
                likes: 34)

u1 = User.create!(first: 'Sophia',
                last: 'Goffe',
                email: 'sgoffe@colslay.edu',
                bio: 'living loving and laughing')

u2 = User.create!(first: 'Meghan',
                last: 'Subak',
                email: 'msubak@colslay.edu',
                bio: 'body builder and book lover')

u3 = User.create!(first: 'Mickey',
                last: 'Mouse',
                email: "mmouse@colslay.edu",
                bio: 'a sassy little mouse')
