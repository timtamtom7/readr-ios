import SwiftUI

struct QuoteSelectionView: View {
    @ObservedObject var viewModel: CaptureViewModel
    @EnvironmentObject var libraryVM: LibraryViewModel
    @Environment(\.dismiss) private var dismiss

    @State private var showingBookPicker = false
    @State private var matchedBook: Book?

    var body: some View {
        NavigationStack {
            ZStack {
                DesignTokens.background
                    .ignoresSafeArea()

                if viewModel.isProcessing {
                    processingView
                } else {
                    scrollContent
                }
            }
            .navigationTitle("Select a Quote")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button {
                        Theme.Haptics.light()
                        viewModel.reset()
                    } label: {
                        Image(systemName: "xmark")
                            .foregroundStyle(DesignTokens.secondaryText)
                    }
                    .accessibilityLabel("Cancel and reset")
                }
            }
            .sheet(isPresented: $showingBookPicker) {
                BookPickerSheet(selectedBook: $matchedBook, books: libraryVM.books)
            }
        }
    }

    private var processingView: some View {
        VStack(spacing: 20) {
            ProgressView()
                .scaleEffect(1.5)
                .tint(DesignTokens.accent)

            Text("Reading the page...")
                .font(.headline)
                .foregroundStyle(DesignTokens.primaryText)
        }
    }

    private var scrollContent: some View {
        ScrollView {
            VStack(spacing: 24) {
                // OCR'd text display
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Text("Detected Text")
                            .font(.caption)
                            .fontWeight(.semibold)
                            .foregroundStyle(DesignTokens.secondaryText)
                            .textCase(.uppercase)

                        Spacer()

                        Text("\(viewModel.recognizedText.count) chars")
                            .font(.caption)
                            .foregroundStyle(DesignTokens.secondaryText)
                    }

                    if let errorMsg = viewModel.errorMessage, viewModel.recognizedText.isEmpty {
                        // OCR failed state
                        VStack(spacing: 12) {
                            Image(systemName: "doc.text.magnifyingglass")
                                .font(.title)
                                .foregroundStyle(DesignTokens.accent.opacity(0.6))

                            Text(errorMsg)
                                .font(.body)
                                .foregroundStyle(DesignTokens.secondaryText)
                                .multilineTextAlignment(.center)

                            Button("Try Again") {
                                viewModel.reset()
                            }
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(DesignTokens.accent)
                        }
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(DesignTokens.surface, in: RoundedRectangle(cornerRadius: 12))
                    } else if viewModel.recognizedText.isEmpty {
                        Text("No text detected. Try again with clearer image.")
                            .font(.body)
                            .foregroundStyle(DesignTokens.secondaryText)
                            .italic()
                            .padding()
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(DesignTokens.surface, in: RoundedRectangle(cornerRadius: 12))
                    } else {
                        Text(viewModel.recognizedText)
                            .font(.system(.body, design: .serif))
                            .foregroundStyle(DesignTokens.primaryText)
                            .padding()
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(DesignTokens.surface, in: RoundedRectangle(cornerRadius: 12))
                            .textSelection(.enabled)
                    }
                }

                // Quote selection
                VStack(alignment: .leading, spacing: 12) {
                    Text("Your Quote")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundStyle(DesignTokens.secondaryText)
                        .textCase(.uppercase)

                    TextEditor(text: $viewModel.selectedQuoteText)
                        .font(.system(.body, design: .serif))
                        .foregroundStyle(DesignTokens.primaryText)
                        .scrollContentBackground(.hidden)
                        .padding()
                        .frame(minHeight: 120)
                        .background(DesignTokens.surface, in: RoundedRectangle(cornerRadius: 12))
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(DesignTokens.accent.opacity(0.3), lineWidth: 1)
                        )

                    Text("Select or type the exact quote you want to save")
                        .font(.caption)
                        .foregroundStyle(DesignTokens.secondaryText)
                }

                // Book info
                VStack(spacing: 16) {
                    HStack {
                        Text("Book")
                            .font(.caption)
                            .fontWeight(.semibold)
                            .foregroundStyle(DesignTokens.secondaryText)
                            .textCase(.uppercase)
                        Spacer()
                    }

                    if let book = matchedBook {
                        HStack {
                            Image(systemName: "book.closed.fill")
                                .foregroundStyle(DesignTokens.accent)

                            VStack(alignment: .leading) {
                                Text(book.title)
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                                    .foregroundStyle(DesignTokens.primaryText)
                                if !book.author.isEmpty {
                                    Text(book.author)
                                        .font(.caption)
                                        .foregroundStyle(DesignTokens.secondaryText)
                                }
                            }

                            Spacer()

                            Button {
                                Theme.Haptics.light()
                                showingBookPicker = true
                            } label: {
                                Text("Change")
                            }
                            .font(.caption)
                            .foregroundStyle(DesignTokens.accent)
                            .accessibilityLabel("Change linked book")
                        }
                        .padding()
                        .background(DesignTokens.surface, in: RoundedRectangle(cornerRadius: 12))
                    } else {
                        Button {
                            Theme.Haptics.light()
                            showingBookPicker = true
                        } label: {
                            HStack {
                                Image(systemName: "plus.circle")
                                Text("Link to existing book")
                            }
                            .font(.subheadline)
                            .foregroundStyle(DesignTokens.accent)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(DesignTokens.surface, in: RoundedRectangle(cornerRadius: 12))
                        }
                        .accessibilityLabel("Link to existing book")
                    }
                }

                // Manual entry fields
                VStack(alignment: .leading, spacing: 12) {
                    Text("Or enter manually")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundStyle(DesignTokens.secondaryText)
                        .textCase(.uppercase)

                    TextField("Book title", text: $viewModel.bookTitle)
                        .textFieldStyle(.plain)
                        .padding()
                        .background(DesignTokens.surface, in: RoundedRectangle(cornerRadius: 12))

                    TextField("Author (optional)", text: $viewModel.bookAuthor)
                        .textFieldStyle(.plain)
                        .padding()
                        .background(DesignTokens.surface, in: RoundedRectangle(cornerRadius: 12))
                }

                // Save button
                Button {
                    Theme.Haptics.success()
                    viewModel.saveQuote(for: matchedBook, libraryVM: libraryVM)
                    dismiss()
                } label: {
                    Text("Save Quote")
                        .font(.headline)
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(
                            viewModel.selectedQuoteText.isEmpty
                                ? DesignTokens.secondaryText
                                : DesignTokens.accent
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                }
                .disabled(viewModel.selectedQuoteText.isEmpty)
                .padding(.top, 8)
                .accessibilityLabel("Save quote")
            }
            .padding()
        }
    }
}

struct BookPickerSheet: View {
    @Binding var selectedBook: Book?
    let books: [Book]
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            List(books) { book in
                Button {
                    Theme.Haptics.selection()
                    selectedBook = book
                    dismiss()
                } label: {
                    HStack {
                        VStack(alignment: .leading) {
                            Text(book.title)
                                .font(.subheadline)
                                .fontWeight(.medium)
                                .foregroundStyle(DesignTokens.primaryText)
                            if !book.author.isEmpty {
                                Text(book.author)
                                    .font(.caption)
                                    .foregroundStyle(DesignTokens.secondaryText)
                            }
                        }

                        Spacer()

                        if selectedBook?.id == book.id {
                            Image(systemName: "checkmark")
                                .foregroundStyle(DesignTokens.accent)
                        }
                    }
                }
            }
            .navigationTitle("Link to Book")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
    }
}

#Preview {
    QuoteSelectionView(viewModel: {
        let vm = CaptureViewModel()
        vm.recognizedText = "The only way to do great work is to love what you do. If you haven't found it yet, keep looking. Don't settle."
        return vm
    }())
    .environmentObject(LibraryViewModel())
}
