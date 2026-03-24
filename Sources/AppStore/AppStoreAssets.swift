import SwiftUI

// MARK: - App Store Assets & Metadata

enum AppStoreMetadata {
    // MARK: - App Name
    static let appName = "Readr"

    // MARK: - Tagline (short, 30 chars)
    static let tagline = "Remember what you read."

    // MARK: - Description (3-4 compelling paragraphs)
    static let description = """
    Every book leaves marks on you. Readr makes sure you remember them.

    Photograph any page of any physical book. Readr's intelligent OCR detects the text, you select the exact quote you want to keep, and it's saved to your personal library — organized by book, ready to revisit. Ten seconds from page to permanent memory.

    Your library grows into something valuable: a curated collection of every passage that made you stop, think, or feel something. Flip through it when you need inspiration, when you're writing, or when you want to remember why a book mattered to you. All your highlights, in one place.

    Readr is for readers. People who annotate, dog-ear pages, and underline sentences that land. People who want their reading life to be more than a list of finished books. Start scanning — and start remembering.
    """

    // MARK: - Keywords (comma-separated, 100 char limit per keyword group)
    static let keywords = [
        "book quotes",
        "read highlights",
        "scan book pages",
        "ocr reading app",
        "quote collector",
        "reading library",
        "book notes",
        "text scanner",
        "book lover gift",
        "study app",
        "citation generator",
        "bibtex export",
        "reading tracker",
        "book annotation",
        "quote keeper"
    ].joined(separator: ", ")

    // MARK: - Marketing Pitch (what's new / key features bullet points)
    static let marketingPitch = """
    • Photograph any book page — intelligent page detection & OCR
    • Select the exact quote you want to keep
    • Built-in library organized by book
    • Export quotes to PDF
    • Cloud sync across all your devices
    • Tags, highlights & reading analytics (Pro)
    • Citation export: BibTeX, APA, MLA (Scholar)
    """

    // MARK: - Category
    static let category = "Education"
    static let subcategory = "Books"

    // MARK: - Age Rating
    static let ageRating = "4+" // Everyone

    // MARK: - App Icon Concept Description
    static let iconConceptDescription = """
    App Icon Concept: "Open Book with Light"

    Design: A minimal open book rendered in warm amber (#c87b4f) on a cream (#faf8f5) background. Subtle light rays emanate from the book's spine, suggesting knowledge being captured. The book is stylized — clean lines, not overly detailed — matching the app's editorial aesthetic. The app name "Readr" appears below the icon in a clean sans-serif (SF Pro) at the bottom of the icon.

    Alternative concept: A viewfinder frame shaped like a book page, with the corner folded, suggesting the act of capturing a page. Warm amber accents.

    All required sizes: 1024x1024 (App Store), plus standard iOS icon sizes.
    """

    // MARK: - Screenshots Guidance
    static let screenshotDescriptions = [
        "Library grid — warm cream background, book cards with paper texture, quote counts visible",
        "Camera capture view — clean viewfinder over a book page, subtle page detection guides",
        "Quote selection — OCR'd text displayed in serif font, draggable selection handles",
        "Book detail — cover placeholder, quote list in paper-textured cards",
        "Pricing sheet — 3-tier card layout with warm paper aesthetic"
    ]

    // MARK: - Support URL
    static let supportURL = "https://readr.app/support"

    // MARK: - Privacy Policy URL
    static let privacyURL = "https://readr.app/privacy"
}

// MARK: - Sample Content for Previews & Mock Data

enum SampleContent {
    // MARK: - Real Book Titles
    static let books: [(title: String, author: String)] = [
        ("Sapiens", "Yuval Noah Harari"),
        ("Atomic Habits", "James Clear"),
        ("The Design of Everyday Things", "Don Norman"),
        ("Thinking, Fast and Slow", "Daniel Kahneman"),
        ("The Anthropocene Reviewed", "John Green"),
        ("Kitchen Confidential", "Anthony Bourdain"),
        ("Educated", "Tara Westover"),
        ("The Gene", "Siddhartha Mukherjee"),
        ("Quiet", "Susan Cain"),
        ("Becoming", "Michelle Obama"),
        ("The Brief History of the Dead", "Kevin Brockmeier"),
        ("Stoner", "John Williams"),
        ("All the Light We Cannot See", "Anthony Doerr"),
        ("Pachinko", "Min Jin Lee"),
        ("The Spirit of the Soil", "Paul Thompson")
    ]

    // MARK: - Realistic Quote Examples
    static let quotes: [(quote: String, book: String, author: String)] = [
        (
            "The chief feature of language is its ability to create abstractions, to communicate about things that do not exist in the physical world.",
            "Sapiens",
            "Yuval Noah Harari"
        ),
        (
            "You do not rise to the level of your goals. You fall to the level of your systems.",
            "Atomic Habits",
            "James Clear"
        ),
        (
            "The human mind is a story processor, not a logic processor.",
            "The Design of Everyday Things",
            "Don Norman"
        ),
        (
            "Nothing in life is as important as you think it is while you are thinking about it.",
            "Thinking, Fast and Slow",
            "Daniel Kahneman"
        ),
        (
            "I am a firm believer in the school of thought that says you can never really know a place until you know at least three people who live there.",
            "The Anthropocene Reviewed",
            "John Green"
        ),
        (
            "The whole world is an exercise in making the same point in slightly different ways, over and over again, and waiting for someone to notice.",
            "Kitchen Confidential",
            "Anthony Bourdain"
        ),
        (
            "You can love someone and still choose to say goodbye to them.",
            "Educated",
            "Tara Westover"
        ),
        (
            "The single greatest challenge of the twenty-first century is not terrorism or war or climate change. It is the force of our own curious, creative, restless minds.",
            "The Gene",
            "Siddhartha Mukherjee"
        ),
        (
            "Solitude is a tool. It brings out the best in people.",
            "Quiet",
            "Susan Cain"
        ),
        (
            "Leadership is not about being in charge. It is about taking care of those in your charge.",
            "Becoming",
            "Michelle Obama"
        )
    ]

    // MARK: - Empty State Copy
    static let emptyLibraryHeadline = "Your library is waiting"
    static let emptyLibrarySubtext = "Every book you've loved has passages worth keeping. Scan your first page and start building a collection of the ideas that shaped you."
    static let emptyQuotesSubtext = "Flip through the pages you've already photographed. Tap a page to select a quote, or scan more pages from this book."

    // MARK: - Camera Tip Copy
    static let cameraTip = "Hold parallel to the page"
    static let cameraSubtip = "Best results in natural light"

    // MARK: - Capture Flow Copy
    static let processingMessage = "Reading the page..."
    static let noTextDetected = "No text detected. Try again with clearer image."
    static let quotePrompt = "Select or type the exact quote you want to save"

    // MARK: - Book Recommendations (for Scholar tier)
    static let recommendations: [(basedOn: String, recommended: String, author: String)] = [
        ("Sapiens", "Homo Deus", "Yuval Noah Harari"),
        ("Atomic Habits", "The Power of Habit", "Charles Duhigg"),
        ("Thinking, Fast and Slow", "Predictably Irrational", "Dan Ariely"),
        ("Quiet", "The Introvert Advantage", "Marti Olsen Laney"),
        ("The Anthropocene Reviewed", "A Short History of Nearly Everything", "Bill Bryson")
    ]
}
