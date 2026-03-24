import SwiftUI

struct CollectionsView: View {
    @EnvironmentObject var libraryVM: LibraryViewModel
    @State private var selectedCollection: Collection?
    @State private var showingCreateSheet = false
    @State private var newCollectionName = ""
    @State private var newCollectionIcon = "folder"

    private let iconOptions = ["bookmark", "book", "checkmark.bookmark", "star", "heart", "folder", "tag", "flag", "lightbulb", "graduationcap"]

    var body: some View {
        NavigationStack {
            ZStack {
                DesignTokens.background
                    .ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 20) {
                        // Collection cards grid
                        LazyVGrid(columns: [GridItem(.adaptive(minimum: 150, maximum: 200), spacing: 16)], spacing: 16) {
                            ForEach(libraryVM.collections) { collection in
                                CollectionCard(collection: collection, bookCount: bookCount(for: collection))
                                    .onTapGesture {
                                        selectedCollection = collection
                                    }
                                    .contextMenu {
                                        if !collection.isSystem {
                                            Button(role: .destructive) {
                                                libraryVM.deleteCollection(collection)
                                            } label: {
                                                Label("Delete", systemImage: "trash")
                                            }
                                        }
                                    }
                            }
                        }
                        .padding(.horizontal)
                    }
                    .padding(.top)
                }
            }
            .navigationTitle("Collections")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        showingCreateSheet = true
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .font(.title2)
                            .foregroundStyle(DesignTokens.accent)
                    }
                }
            }
            .sheet(item: $selectedCollection) { collection in
                CollectionDetailView(collection: collection)
                    .environmentObject(libraryVM)
            }
            .sheet(isPresented: $showingCreateSheet) {
                createCollectionSheet
            }
        }
    }

    private func bookCount(for collection: Collection) -> Int {
        (try? DatabaseService.shared.fetchBooksForCollection(collectionIdValue: collection.id).count) ?? 0
    }

    private var createCollectionSheet: some View {
        NavigationStack {
            ZStack {
                DesignTokens.background
                    .ignoresSafeArea()

                VStack(spacing: 24) {
                    TextField("Collection name", text: $newCollectionName)
                        .font(.body)
                        .padding()
                        .background(DesignTokens.surface, in: RoundedRectangle(cornerRadius: 12))
                        .padding(.horizontal)

                    VStack(alignment: .leading, spacing: 12) {
                        Text("Choose an icon")
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(DesignTokens.primaryText)
                            .padding(.horizontal)

                        LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 5), spacing: 12) {
                            ForEach(iconOptions, id: \.self) { icon in
                                Button {
                                    newCollectionIcon = icon
                                } label: {
                                    Image(systemName: icon)
                                        .font(.title2)
                                        .frame(width: 48, height: 48)
                                        .background(
                                            newCollectionIcon == icon
                                                ? DesignTokens.accent
                                                : DesignTokens.surface
                                        )
                                        .foregroundStyle(
                                            newCollectionIcon == icon
                                                ? .white
                                                : DesignTokens.primaryText
                                        )
                                        .clipShape(RoundedRectangle(cornerRadius: 10))
                                }
                            }
                        }
                        .padding(.horizontal)
                    }

                    Spacer()
                }
                .padding(.top)
            }
            .navigationTitle("New Collection")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        newCollectionName = ""
                        showingCreateSheet = false
                    }
                    .foregroundStyle(DesignTokens.secondaryText)
                }
                ToolbarItem(placement: .primaryAction) {
                    Button("Create") {
                        libraryVM.createCollection(name: newCollectionName, iconName: newCollectionIcon)
                        newCollectionName = ""
                        newCollectionIcon = "folder"
                        showingCreateSheet = false
                    }
                    .disabled(newCollectionName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                    .foregroundStyle(DesignTokens.accent)
                }
            }
        }
        .presentationDetents([.medium])
    }
}

// MARK: - Collection Card
struct CollectionCard: View {
    let collection: Collection
    let bookCount: Int

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: collection.iconName)
                    .font(.title)
                    .foregroundStyle(DesignTokens.accent)
                    .frame(width: 44, height: 44)
                    .background(DesignTokens.accent.opacity(0.12))
                    .clipShape(RoundedRectangle(cornerRadius: 10))

                Spacer()

                if collection.isSystem {
                    Text(systemBadge)
                        .font(.caption2.weight(.semibold))
                        .foregroundStyle(DesignTokens.accent)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(DesignTokens.accent.opacity(0.12))
                        .clipShape(Capsule())
                }
            }

            Spacer()

            VStack(alignment: .leading, spacing: 4) {
                Text(collection.name)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(DesignTokens.primaryText)
                    .lineLimit(2)

                Text("\(bookCount) book\(bookCount == 1 ? "" : "s")")
                    .font(.caption)
                    .foregroundStyle(DesignTokens.secondaryText)
            }
        }
        .padding(16)
        .frame(height: 130)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(DesignTokens.surface, in: RoundedRectangle(cornerRadius: 16))
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.black.opacity(0.04), lineWidth: 1)
        )
        .shadow(color: .black.opacity(0.05), radius: 6, x: 0, y: 3)
    }

    private var systemBadge: String {
        switch collection.name {
        case "Want to Read": return "Reading List"
        case "Currently Reading": return "Active"
        case "Finished": return "Complete"
        default: return ""
        }
    }
}

// MARK: - Collection Detail View
struct CollectionDetailView: View {
    let collection: Collection
    @EnvironmentObject var libraryVM: LibraryViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var books: [Book] = []
    @State private var selectedBook: Book?

    private let columns = [
        GridItem(.adaptive(minimum: 150, maximum: 200), spacing: 16)
    ]

    var body: some View {
        NavigationStack {
            ZStack {
                DesignTokens.background
                    .ignoresSafeArea()

                if books.isEmpty {
                    emptyShelfState
                } else {
                    ScrollView {
                        LazyVGrid(columns: columns, spacing: 16) {
                            ForEach(books) { book in
                                BookCard(
                                    book: book,
                                    quoteCount: libraryVM.quoteCounts[book.id] ?? 0
                                )
                                .onTapGesture {
                                    selectedBook = book
                                }
                            }
                        }
                        .padding()
                    }
                }
            }
            .navigationTitle(collection.name)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                            .foregroundStyle(DesignTokens.secondaryText)
                    }
                }
            }
            .sheet(item: $selectedBook) { book in
                BookDetailView(book: book)
                    .environmentObject(libraryVM)
            }
        }
        .onAppear {
            loadBooks()
        }
    }

    private var emptyShelfState: some View {
        VStack(spacing: 20) {
            ZStack {
                Circle()
                    .fill(DesignTokens.accent.opacity(0.08))
                    .frame(width: 120, height: 120)

                Image(systemName: collection.iconName)
                    .font(.system(size: 40))
                    .foregroundStyle(DesignTokens.accent.opacity(0.5))
            }

            VStack(spacing: 8) {
                Text("No books here yet")
                    .font(.headline)
                    .foregroundStyle(DesignTokens.primaryText)

                Text("Add books to \"\(collection.name)\" from your library.")
                    .font(.subheadline)
                    .foregroundStyle(DesignTokens.secondaryText)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
            }
        }
        .padding()
    }

    private func loadBooks() {
        do {
            books = try DatabaseService.shared.fetchBooksForCollection(collectionIdValue: collection.id)
            for book in books {
                libraryVM.quoteCounts[book.id] = (try? DatabaseService.shared.quoteCount(forBookId: book.id)) ?? 0
            }
        } catch {
            // silent fail
        }
    }
}

#Preview {
    CollectionsView()
        .environmentObject(LibraryViewModel())
}
