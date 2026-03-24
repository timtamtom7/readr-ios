import SwiftUI

struct LibraryView: View {
    @EnvironmentObject var libraryVM: LibraryViewModel
    @State private var showingCapture = false
    @State private var selectedBook: Book?

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
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        showingCapture = true
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .font(.title2)
                            .foregroundStyle(DesignTokens.accent)
                    }
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
                        Button(role: .destructive) {
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

#Preview {
    LibraryView()
        .environmentObject(LibraryViewModel())
}
