import WidgetKit
import SwiftUI

// MARK: - Widget Entry
struct QuoteEntry: TimelineEntry {
    let date: Date
    let quote: String
    let bookTitle: String
    let author: String
}

// MARK: - Timeline Provider
struct QuoteProvider: TimelineProvider {
    func placeholder(in context: Context) -> QuoteEntry {
        QuoteEntry(
            date: Date(),
            quote: "The only way to do great work is to love what you do.",
            bookTitle: "Steve Jobs",
            author: "Walter Isaacson"
        )
    }

    func getSnapshot(in context: Context, completion: @escaping (QuoteEntry) -> Void) {
        let entry = loadRandomQuoteEntry() ?? placeholder(in: context)
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<QuoteEntry>) -> Void) {
        let entry = loadRandomQuoteEntry() ?? placeholder(in: context)
        // Refresh every 6 hours
        let nextUpdate = Calendar.current.date(byAdding: .hour, value: 6, to: Date())!
        let timeline = Timeline(entries: [entry], policy: .after(nextUpdate))
        completion(timeline)
    }

    private func loadRandomQuoteEntry() -> QuoteEntry? {
        let defaults = UserDefaults(suiteName: "group.com.readr.app")
        guard let quote = defaults?.string(forKey: "widget_quote"),
              let bookTitle = defaults?.string(forKey: "widget_book_title"),
              let author = defaults?.string(forKey: "widget_author") else {
            return nil
        }
        return QuoteEntry(date: Date(), quote: quote, bookTitle: bookTitle, author: author)
    }
}

// MARK: - Small Widget View
struct SmallWidgetView: View {
    let entry: QuoteEntry

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Image(systemName: "quote.opening")
                .font(.caption)
                .foregroundStyle(Color(hex: "c87b4f"))

            Spacer()

            Text("\"\(entry.quote.prefix(80))...\"")
                .font(.system(.caption, design: .serif))
                .foregroundStyle(.primary)
                .lineLimit(4)
                .multilineTextAlignment(.leading)

            Spacer()

            Text(entry.bookTitle)
                .font(.caption2)
                .foregroundStyle(.secondary)
                .lineLimit(1)
        }
        .padding(12)
        .containerBackground(for: .widget) {
            Color(hex: "faf8f5")
        }
    }
}

// MARK: - Medium Widget View
struct MediumWidgetView: View {
    let entry: QuoteEntry

    var body: some View {
        HStack(spacing: 12) {
            // Left decorative bar
            Rectangle()
                .fill(Color(hex: "c87b4f"))
                .frame(width: 3)
                .clipShape(RoundedRectangle(cornerRadius: 2))

            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Image(systemName: "quote.opening")
                        .font(.caption)
                        .foregroundStyle(Color(hex: "c87b4f"))
                    Spacer()
                    Text("Readr")
                        .font(.caption2)
                        .foregroundStyle(.tertiary)
                }

                Text("\"\(entry.quote)\"")
                    .font(.system(.subheadline, design: .serif))
                    .foregroundStyle(.primary)
                    .lineLimit(3)
                    .multilineTextAlignment(.leading)

                VStack(alignment: .leading, spacing: 2) {
                    Text(entry.bookTitle)
                        .font(.caption.weight(.medium))
                        .foregroundStyle(.secondary)

                    if !entry.author.isEmpty {
                        Text(entry.author)
                            .font(.caption2)
                            .foregroundStyle(.tertiary)
                    }
                }
            }
        }
        .padding(14)
        .containerBackground(for: .widget) {
            Color(hex: "faf8f5")
        }
    }
}

// MARK: - Widget Configuration
struct ReadrWidget: Widget {
    let kind: String = "ReadrWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: QuoteProvider()) { entry in
            if #available(iOS 17.0, *) {
                WidgetEntryView(entry: entry)
            } else {
                WidgetEntryView(entry: entry)
            }
        }
        .configurationDisplayName("Quote of the Day")
        .description("A random quote from your Readr library.")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}

// MARK: - Widget Entry View (dispatches to size)
struct WidgetEntryView: View {
    @Environment(\.widgetFamily) var family
    let entry: QuoteEntry

    var body: some View {
        switch family {
        case .systemSmall:
            SmallWidgetView(entry: entry)
        case .systemMedium:
            MediumWidgetView(entry: entry)
        default:
            SmallWidgetView(entry: entry)
        }
    }
}

// MARK: - Color Extension
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3:
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6:
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8:
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

// MARK: - Widget Bundle
@main
struct ReadrWidgetBundle: WidgetBundle {
    var body: some Widget {
        ReadrWidget()
    }
}

#Preview(as: .systemSmall) {
    ReadrWidget()
} timeline: {
    QuoteEntry(
        date: Date(),
        quote: "The only way to do great work is to love what you do.",
        bookTitle: "Steve Jobs",
        author: "Walter Isaacson"
    )
}

#Preview(as: .systemMedium) {
    ReadrWidget()
} timeline: {
    QuoteEntry(
        date: Date(),
        quote: "The only way to do great work is to love what you do. If you haven't found it yet, keep looking. Don't settle.",
        bookTitle: "Steve Jobs",
        author: "Walter Isaacson"
    )
}
