import SwiftUI

struct LibraryView: View {
    @EnvironmentObject var libraryVM: LibraryViewModel
    @State private var showingCapture = false
    @State private var selectedBook: Book?
    @State private var showingSearch = false
    @State private var showingCollections = false
    @State private var bookToMove: Book?
    @State private var showingMoveSheet = false

    private let columns = [
        GridItem(.adaptive(minimum: 150, maximum: 200), spacing: 16)
    ]

    var body: some View {
        NavigationStack {
            ZStack {
                DesignTokens.background
                    .ignoresSafeArea()

                if libraryVM.isLoading {
                    ProgressView()
                        .tint(DesignTokens.accent)
                } else if libraryVM.books.isEmpty {
                    emptyState
                } else {
                    bookGrid
                }
            }
            .navigationTitle("Library")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        Theme.Haptics.light()
                        showingCollections = true
                    } label: {
                        Image(systemName: "books.vertical.fill")
                            .font(.title3)
                            .foregroundStyle(DesignTokens.accent)
                    }
                    .accessibilityLabel("Collections")
                }

                ToolbarItem(placement: .topBarTrailing) {
                    HStack(spacing: 16) {
                        Button {
                            Theme.Haptics.light()
                            showingSearch = true
                        } label: {
                            Image(systemName: "magnifyingglass")
                                .font(.title3)
                                .foregroundStyle(DesignTokens.secondaryText)
                        }
                        .accessibilityLabel("Search books")
                    }
                }

                ToolbarItem(placement: .primaryAction) {
                    Button {
                        Theme.Haptics.medium()
                        showingCapture = true
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .font(.title2)
                            .foregroundStyle(DesignTokens.accent)
                    }
                    .accessibilityLabel("Capture new book")
                }
            }
            .sheet(isPresented: $showingCapture) {
                CaptureFlowView()
                    .environmentObject(libraryVM)
            }
            .sheet(item: $selectedBook) { book in
                BookDetailView(book: book)
                    .environmentObject(libraryVM)
            }
            .sheet(isPresented: $showingSearch) {
                SearchView()
                    .environmentObject(libraryVM)
            }
            .sheet(isPresented: $showingCollections) {
                CollectionsView()
                    .environmentObject(libraryVM)
            }
            .sheet(item: $bookToMove) { book in
                MoveToCollectionSheet(book: book)
                    .environmentObject(libraryVM)
            }
        }
    }

    private var emptyState: some View {
        EmptyLibraryView {
            showingCapture = true
        }
    }

    private var bookGrid: some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: 16) {
                ForEach(libraryVM.books) { book in
                    BookCard(
                        book: book,
                        quoteCount: libraryVM.quoteCounts[book.id] ?? 0
                    )
                    .onTapGesture {
                        selectedBook = book
                    }
                    .contextMenu {
                        Button {
                            Theme.Haptics.light()
                            bookToMove = book
                        } label: {
                            Label("Add to Collection", systemImage: "folder.badge.plus")
                        }

                        Button(role: .destructive) {
                            Theme.Haptics.warning()
                            libraryVM.deleteBook(book)
                        } label: {
                            Label("Delete", systemImage: "trash")
                        }
                    }
                }
            }
            .padding()
        }
        .refreshable {
            libraryVM.loadBooks()
        }
    }
}

// MARK: - Move to Collection Sheet
struct MoveToCollectionSheet: View {
    let book: Book
    @EnvironmentObject var libraryVM: LibraryViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var bookCollections: [Collection] = []

    var body: some View {
        NavigationStack {
            ZStack {
                DesignTokens.background
                    .ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 12) {
                        ForEach(libraryVM.collections) { collection in
                            CollectionRow(
                                collection: collection,
                                isSelected: bookCollections.contains(where: { $0.id == collection.id })
                            )
                            .onTapGesture {
                                toggleCollection(collection)
                            }
                        }
                    }
                    .padding()
                }
            }
            .navigationTitle("Add to Collection")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Done") {
                        dismiss()
                    }
                    .foregroundStyle(DesignTokens.accent)
                }
            }
        }
        .onAppear {
            bookCollections = libraryVM.collectionsForBook(book.id)
        }
    }

    private func toggleCollection(_ collection: Collection) {
        if bookCollections.contains(where: { $0.id == collection.id }) {
            libraryVM.removeBookFromCollection(bookId: book.id, collectionId: collection.id)
            bookCollections.removeAll { $0.id == collection.id }
        } else {
            libraryVM.addBookToCollection(bookId: book.id, collectionId: collection.id)
            bookCollections.append(collection)
        }
    }
}

// MARK: - Collection Row
struct CollectionRow: View {
    let collection: Collection
    let isSelected: Bool

    var body: some View {
        HStack(spacing: 14) {
            Image(systemName: collection.iconName)
                .font(.title3)
                .foregroundStyle(isSelected ? .white : DesignTokens.accent)
                .frame(width: 40, height: 40)
                .background(isSelected ? DesignTokens.accent : DesignTokens.accent.opacity(0.12))
                .clipShape(RoundedRectangle(cornerRadius: 10))

            Text(collection.name)
                .font(.subheadline.weight(.medium))
                .foregroundStyle(DesignTokens.primaryText)

            Spacer()

            if isSelected {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundStyle(DesignTokens.accent)
            } else {
                Image(systemName: "plus.circle")
                    .foregroundStyle(DesignTokens.secondaryText.opacity(0.5))
            }
        }
        .padding(14)
        .background(DesignTokens.surface, in: RoundedRectangle(cornerRadius: 12))
    }
}

#Preview {
    LibraryView()
        .environmentObject(LibraryViewModel())
}
