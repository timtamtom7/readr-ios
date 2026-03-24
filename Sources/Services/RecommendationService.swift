import Foundation

// MARK: - Recommendation Service
final class RecommendationService: @unchecked Sendable {
    static let shared = RecommendationService()

    private init() {}

    // MARK: - Genre Detection

    private let genreKeywords: [String: [String]] = [
        "Philosophy": ["philosophy", " plato", " aristotle", " nietzsche", " kant", " existential", "socrates", "confucius", "seneca", "marcus aurelius", "ethics", "metaphysics", "logic"],
        "Science": ["science", "physics", "biology", "chemistry", "cosmos", "universe", "evolution", "quantum", "einstein", "hawking", "sagan", "carbon", "gene", "atom"],
        "Technology": ["code", "programming", "software", "computer", "algorithm", "data", "machine learning", "ai", "python", "swift", "engineering", "tech", "silicon"],
        "Psychology": ["psychology", "mind", "brain", "behavior", "cognitive", "therapy", "freud", "jung", "neuroscience", "emotion", "memory", "consciousness", "personality"],
        "History": ["history", "war", "empire", "ancient", "medieval", "world war", "civilization", "revolution", "century", "historical", "king", "queen", "nation"],
        "Business": ["business", "startup", "entrepreneur", "leadership", "management", "strategy", "marketing", "money", "finance", "investment", "wealth", "economy", "market"],
        "Self-Help": ["self-help", "self improvement", "habit", "productivity", "motivation", "happiness", "success", "goal", "mindset", "focus", "discipline", "growth"],
        "Fiction": ["novel", "fiction", "story", "narrative", "character", "plot", "chapter", "series", "fantasy", "thriller", "mystery", "romance", "literary"],
        "Biography": ["biography", "memoir", "autobiography", "life of", "memoirs", "personal", "life story", "diary", "journal", "diaries"],
        "Spirituality": ["spiritual", "meditation", "buddha", "buddhism", "hindu", "yoga", "zen", "tao", "kundalini", "enlightenment", "soul", "consciousness", "awakening", "rumi", "dalai"],
        "Economics": ["economics", "capitalism", "marx", "keynes", "trade", "inflation", "gdp", "federal reserve", "money", "monetary", "fiscal"],
        "Politics": ["political", "government", "democracy", "republic", "constitution", "liberal", "conservative", "policy", "vote", "election", "trump", "biden", "obama"],
        "Sociology": ["sociology", "society", "social", "culture", "community", "population", "inequality", "poverty", "race", "gender", "identity", "structural"],
        "Art": ["art", "painting", "sculpture", "gallery", "museum", "aesthetic", "design", "architecture", "van gogh", "picasso", "visual", "creative"],
        "Music": ["music", "musician", "composer", "symphony", "jazz", "rock", "classical", "song", "album", "band", "concert", "beethoven", "mozart", "bach"]
    ]

    private let recommendations: [String: [BookRecommendation]] = [
        "Philosophy": [
            BookRecommendation(title: "Meditations", author: "Marcus Aurelius", reason: "Timeless Stoic wisdom", coverColor: "8b7355"),
            BookRecommendation(title: "The Art of War", author: "Sun Tzu", reason: "Classic strategic thinking", coverColor: "6b5344"),
            BookRecommendation(title: "Letters from a Stoic", author: "Seneca", reason: "Practical ancient philosophy", coverColor: "7a6555"),
            BookRecommendation(title: "Man's Search for Meaning", author: "Viktor Frankl", reason: "Finding purpose in hardship", coverColor: "5a4a3a"),
            BookRecommendation(title: "The Daily Stoic", author: "Ryan Holiday", reason: "366 days of Stoic wisdom", coverColor: "8b7b6b")
        ],
        "Science": [
            BookRecommendation(title: "Cosmos", author: "Carl Sagan", reason: "Journey through the universe", coverColor: "2c3e50"),
            BookRecommendation(title: "Sapiens", author: "Yuval Noah Harari", reason: "Brief history of humankind", coverColor: "34495e"),
            BookRecommendation(title: "A Brief History of Time", author: "Stephen Hawking", reason: "From Big Bang to black holes", coverColor: "1a252f"),
            BookRecommendation(title: "The Gene", author: "Siddhartha Mukherjee", reason: "Intimate history of heredity", coverColor: "2e4a5e"),
            BookRecommendation(title: "The Selfish Gene", author: "Richard Dawkins", reason: "Gene-centered view of evolution", coverColor: "3a5a4a")
        ],
        "Technology": [
            BookRecommendation(title: "Clean Code", author: "Robert C. Martin", reason: "Writing maintainable software", coverColor: "2c3e50"),
            BookRecommendation(title: "The Pragmatic Programmer", author: "David Thomas", reason: "Timeless software craftsmanship", coverColor: "34495e"),
            BookRecommendation(title: "Designing Data-Intensive Applications", author: "Martin Kleppmann", reason: "Big data systems fundamentals", coverColor: "1a252f"),
            BookRecommendation(title: "Structure and Interpretation of Computer Programs", author: "Harold Abelson", reason: "The CS classic", coverColor: "3d5a5a"),
            BookRecommendation(title: "The Manager's Path", author: "Camille Fournier", reason: "Tech leadership ladder", coverColor: "4a3a2a")
        ],
        "Psychology": [
            BookRecommendation(title: "Thinking, Fast and Slow", author: "Daniel Kahneman", reason: "Two systems that drive the way we think", coverColor: "4a5568"),
            BookRecommendation(title: "The Body Keeps the Score", author: "Bessel van der Kolk", reason: "How trauma reshapes body and brain", coverColor: "5a4a3a"),
            BookRecommendation(title: "Atomic Habits", author: "James Clear", reason: "Tiny changes, remarkable results", coverColor: "3a5a3a"),
            BookRecommendation(title: "The Power of Now", author: "Eckhart Tolle", reason: " awakening to your true self", coverColor: "5a6a4a"),
            BookRecommendation(title: "Man's Search for Meaning", author: "Viktor Frankl", reason: "Meaning beyond suffering", coverColor: "5a4a3a")
        ],
        "History": [
            BookRecommendation(title: "Sapiens", author: "Yuval Noah Harari", reason: "A history of humankind", coverColor: "34495e"),
            BookRecommendation(title: "Guns, Germs, and Steel", author: "Jared Diamond", reason: "Fates of human societies", coverColor: "2c3e50"),
            BookRecommendation(title: "The Silk Roads", author: "Peter Frankopan", reason: "A new history of the world", coverColor: "5a4a3a"),
            BookRecommendation(title: "SPQR", author: "Mary Beard", reason: "Ancient Rome's story", coverColor: "6b5344"),
            BookRecommendation(title: "The Rise and Fall of the Third Reich", author: "William L. Shirer", reason: "History of Nazi Germany", coverColor: "3a2a1a")
        ],
        "Business": [
            BookRecommendation(title: "The Lean Startup", author: "Eric Ries", reason: "Build-measure-learn approach", coverColor: "27ae60"),
            BookRecommendation(title: "Zero to One", author: "Peter Thiel", reason: "Notes on startups, or how to build the future", coverColor: "2c3e50"),
            BookRecommendation(title: "Good to Great", author: "Jim Collins", reason: "Why some companies make the leap", coverColor: "34495e"),
            BookRecommendation(title: "The Hard Thing About Hard Things", author: "Ben Horowitz", reason: "Building a business when there are no easy answers", coverColor: "3a2a1a"),
            BookRecommendation(title: "Shoe Dog", author: "Phil Knight", reason: "A memoir by the creator of Nike", coverColor: "5a3a2a")
        ],
        "Self-Help": [
            BookRecommendation(title: "Atomic Habits", author: "James Clear", reason: "Tiny changes, remarkable results", coverColor: "3a5a3a"),
            BookRecommendation(title: "The 7 Habits of Highly Effective People", author: "Stephen Covey", reason: "Principle-centered approach to life", coverColor: "4a5a4a"),
            BookRecommendation(title: "Deep Work", author: "Cal Newport", reason: "Focus without distraction", coverColor: "3a4a5a"),
            BookRecommendation(title: "The Subtle Art of Not Giving a F*ck", author: "Mark Manson", reason: "Counterintuitive approach to living", coverColor: "5a3a3a"),
            BookRecommendation(title: "Think and Grow Rich", author: "Napoleon Hill", reason: "Classic success principles", coverColor: "6a5a3a")
        ],
        "Fiction": [
            BookRecommendation(title: "The Alchemist", author: "Paulo Coelho", reason: "A shepherd's journey to find his treasure", coverColor: "c87b4f"),
            BookRecommendation(title: "One Hundred Years of Solitude", author: "Gabriel García Márquez", reason: "Multi-generational saga", coverColor: "7b6b8a"),
            BookRecommendation(title: "The Great Gatsby", author: "F. Scott Fitzgerald", reason: "American Dream's dark side", coverColor: "8b7b6b"),
            BookRecommendation(title: "Norwegian Wood", author: "Haruki Murakami", reason: "Loss, love, and healing", coverColor: "5a6b5a"),
            BookRecommendation(title: "Crime and Punishment", author: "Fyodor Dostoevsky", reason: "Guilt and redemption in St. Petersburg", coverColor: "4a3a3a")
        ],
        "Biography": [
            BookRecommendation(title: "Steve Jobs", author: "Walter Isaacson", reason: "The definitive biography", coverColor: "3a3a3a"),
            BookRecommendation(title: "Einstein: His Life and Universe", author: "Walter Isaacson", reason: "Genius and the nature of science", coverColor: "4a4a5a"),
            BookRecommendation(title: "Leonardo da Vinci", author: "Walter Isaacson", reason: "The polymath's infinite curiosity", coverColor: "5a5a4a"),
            BookRecommendation(title: "The Diary of a Young Girl", author: "Anne Frank", reason: "An enduring voice of hope", coverColor: "8b4a4a"),
            BookRecommendation(title: "Long Walk to Freedom", author: "Nelson Mandela", reason: "Journey from prison to president", coverColor: "4a4a3a")
        ],
        "Spirituality": [
            BookRecommendation(title: "The Power of Now", author: "Eckhart Tolle", reason: " awakening to your true self", coverColor: "5a6a4a"),
            BookRecommendation(title: "The Untethered Soul", author: "Michael A. Singer", reason: "Journey beyond yourself", coverColor: "6a7a5a"),
            BookRecommendation(title: "Be Here Now", author: "Ram Dass", reason: "Mindfulness classic", coverColor: "7a8a6a"),
            BookRecommendation(title: "A New Earth", author: "Eckhart Tolle", reason: "Create a better world", coverColor: "5a5a4a"),
            BookRecommendation(title: "The Book of Secrets", author: "Osho", reason: "112 meditations to unlock your inner world", coverColor: "8a7a5a")
        ],
        "Economics": [
            BookRecommendation(title: "Capital in the Twenty-First Century", author: "Thomas Piketty", reason: "Wealth inequality across time", coverColor: "34495e"),
            BookRecommendation(title: "The Wealth of Nations", author: "Adam Smith", reason: "Foundation of modern economics", coverColor: "2c3e50"),
            BookRecommendation(title: "Freakonomics", author: "Steven Levitt", reason: "Hidden side of everything", coverColor: "5a4a3a"),
            BookRecommendation(title: "Thinking, Fast and Slow", author: "Daniel Kahneman", reason: "Economics meets psychology", coverColor: "4a5568"),
            BookRecommendation(title: "The Black Swan", author: "Nassim Taleb", reason: "Impact of the improbable", coverColor: "3a3a4a")
        ],
        "Politics": [
            BookRecommendation(title: "The Prince", author: "Machiavelli", reason: "Power and statecraft", coverColor: "5a4a3a"),
            BookRecommendation(title: "The Republic", author: "Plato", reason: "Justice and the ideal state", coverColor: "6b5344"),
            BookRecommendation(title: "1984", author: "George Orwell", reason: "Surveillance and authoritarianism", coverColor: "4a4a4a"),
            BookRecommendation(title: "Animal Farm", author: "George Orwell", reason: "Power corrupts", coverColor: "5a5a4a"),
            BookRecommendation(title: "On War", author: "Clausewitz", reason: "Military strategy foundations", coverColor: "3a3a2a")
        ],
        "Sociology": [
            BookRecommendation(title: "The Tipping Point", author: "Malcolm Gladwell", reason: "How little things make a big difference", coverColor: "c0392b"),
            BookRecommendation(title: "Outliers", author: "Malcolm Gladwell", reason: "What makes high-achievers different", coverColor: "2980b9"),
            BookRecommendation(title: "Bowling Alone", author: "Robert Putnam", reason: "Collapse of American community", coverColor: "5a6a5a"),
            BookRecommendation(title: "The Social Animal", author: "Elliot Aronson", reason: "Unconscious foundations of social behavior", coverColor: "6a5a4a"),
            BookRecommendation(title: "The Presentation of Self in Everyday Life", author: "Erving Goffman", reason: "Theatrical metaphor of social interaction", coverColor: "4a4a5a")
        ],
        "Art": [
            BookRecommendation(title: "The Story of Art", author: "E.H. Gombrich", reason: "The most popular art book ever", coverColor: "8b7b6b"),
            BookRecommendation(title: "Ways of Seeing", author: "John Berger", reason: "How we look at art differently", coverColor: "6b5b4b"),
            BookRecommendation(title: "Steal Like an Artist", author: "Austin Kleon", reason: "Creativity is everywhere", coverColor: "7a6a5a"),
            BookRecommendation(title: "The Art of Looking Sideways", author: "Alan Fletcher", reason: "Exhaustive compendium of visual ideas", coverColor: "5a4a3a"),
            BookRecommendation(title: "Visionary VGA", author: "Various", reason: "Design and visual communication", coverColor: "4a5a6a")
        ],
        "Music": [
            BookRecommendation(title: "How Music Works", author: "David Byrne", reason: "Music's place in the world", coverColor: "5a4a6a"),
            BookRecommendation(title: "Every Song Ever", author: "Ben Ratliff", reason: "Twenty ways to listen to music now", coverColor: "6a5a5a"),
            BookRecommendation(title: "This Is Your Brain on Music", author: "Daniel Levitin", reason: "The science of a human obsession", coverColor: "4a3a5a"),
            BookRecommendation(title: "Love Is a Mix Tape", author: "Rob Sheffield", reason: "Life and loss, one song at a time", coverColor: "7b5b5b"),
            BookRecommendation(title: "The Rest Is Noise", author: "Alex Ross", reason: "Twentieth century music story", coverColor: "3a4a4a")
        ]
    ]

    func detectGenres(for books: [Book]) -> [String] {
        guard !books.isEmpty else { return [] }

        var genreScores: [String: Int] = [:]

        for book in books {
            let text = "\(book.title) \(book.author)".lowercased()
            for (genre, keywords) in genreKeywords {
                for keyword in keywords {
                    if text.contains(keyword) {
                        genreScores[genre, default: 0] += 1
                    }
                }
            }
        }

        let sortedGenres = genreScores.sorted { $0.value > $1.value }
        return Array(sortedGenres.prefix(3).map { $0.key })
    }

    func getRecommendations(for genres: [String], excludingTitles: [String]) -> [BookRecommendation] {
        var seenTitles = Set<String>()
        var results: [BookRecommendation] = []

        for genre in genres {
            if let genreRecs = recommendations[genre] {
                for rec in genreRecs {
                    if !seenTitles.contains(rec.title) && !excludingTitles.contains(rec.title) {
                        seenTitles.insert(rec.title)
                        results.append(rec)
                        if results.count >= 8 { break }
                    }
                }
            }
            if results.count >= 8 { break }
        }

        // Fill with popular cross-genre books if needed
        let crossGenre: [BookRecommendation] = [
            BookRecommendation(title: "Sapiens", author: "Yuval Noah Harari", reason: "A landmark exploration of human history", coverColor: "34495e"),
            BookRecommendation(title: "Thinking, Fast and Slow", author: "Daniel Kahneman", reason: "The two systems that drive the way we think", coverColor: "4a5568"),
            BookRecommendation(title: "Man's Search for Meaning", author: "Viktor Frankl", reason: "Finding purpose in the worst circumstances", coverColor: "5a4a3a"),
            BookRecommendation(title: "The Alchemist", author: "Paulo Coelho", reason: "A shepherd's journey to find his treasure", coverColor: "c87b4f")
        ]

        for rec in crossGenre {
            if results.count >= 8 { break }
            if !seenTitles.contains(rec.title) {
                seenTitles.insert(rec.title)
                results.append(rec)
            }
        }

        return Array(results.prefix(8))
    }

    func getRecommendationsForBooks(_ books: [Book]) -> [BookRecommendation] {
        let genres = detectGenres(for: books)
        let titles = books.map { $0.title }
        return getRecommendations(for: genres, excludingTitles: titles)
    }
}
