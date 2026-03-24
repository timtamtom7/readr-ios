import SwiftUI

// MARK: - Book Notes View
struct BookNotesView: View {
    let book: Book
    @State private var notes: [BookNote] = []
    @State private var isLoading = true
    @State private var showingAddNote = false
    @State private var noteToEdit: BookNote?
    @State private var showingDeleteConfirmation = false
    @State private var noteToDelete: BookNote?

    var body: some View {
        NavigationStack {
            ZStack {
                DesignTokens.background
                    .ignoresSafeArea()

                if isLoading {
                    ProgressView()
                        .tint(DesignTokens.accent)
                } else if notes.isEmpty {
                    emptyNotesState
                } else {
                    notesList
                }
            }
            .navigationTitle("Notes")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button {} label: {
                        Image(systemName: "xmark")
                            .foregroundStyle(DesignTokens.secondaryText)
                    }
                }
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        showingAddNote = true
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .font(.title2)
                            .foregroundStyle(DesignTokens.accent)
                    }
                }
            }
            .sheet(isPresented: $showingAddNote) {
                NoteEditSheet(bookId: book.id, existingNote: nil) { newNote in
                    addNote(newNote)
                }
            }
            .sheet(item: $noteToEdit) { note in
                NoteEditSheet(bookId: book.id, existingNote: note) { updatedNote in
                    updateNote(updatedNote)
                }
            }
            .alert("Delete Note?", isPresented: $showingDeleteConfirmation) {
                Button("Cancel", role: .cancel) {}
                Button("Delete", role: .destructive) { handleDelete() }
            } message: {
                Text("This note will be permanently deleted.")
            }
        }
        .onAppear { loadNotes() }
    }

    private var notesList: some View {
        ScrollView {
            LazyVStack(spacing: 12) {
                ForEach(notes) { note in
                    NoteCard(note: note)
                        .onTapGesture { noteToEdit = note }
                        .contextMenu {
                            Button {
                                noteToEdit = note
                            } label: {
                                Label("Edit", systemImage: "pencil")
                            }
                            Button(role: .destructive) {
                                noteToDelete = note
                                showingDeleteConfirmation = true
                            } label: {
                                Label("Delete", systemImage: "trash")
                            }
                        }
                }
            }
            .padding()
        }
    }

    private var emptyNotesState: some View {
        VStack(spacing: 20) {
            ZStack {
                Circle()
                    .fill(DesignTokens.accent.opacity(0.08))
                    .frame(width: 100, height: 100)

                Image(systemName: "note.text")
                    .font(.system(size: 36))
                    .foregroundStyle(DesignTokens.accent.opacity(0.5))
            }

            Text("No notes yet")
                .font(.headline)
                .foregroundStyle(DesignTokens.primaryText)

            Text("Add personal notes and reflections about this book.")
                .font(.subheadline)
                .foregroundStyle(DesignTokens.secondaryText)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)

            Button {
                showingAddNote = true
            } label: {
                HStack {
                    Image(systemName: "plus")
                    Text("Add First Note")
                }
                .font(.subheadline.weight(.medium))
                .foregroundStyle(.white)
                .padding(.horizontal, 24)
                .padding(.vertical, 12)
                .background(DesignTokens.accent)
                .clipShape(Capsule())
            }
        }
        .padding()
    }

    private func loadNotes() {
        isLoading = true
        DispatchQueue.global(qos: .userInitiated).async {
            let loadedNotes = (try? DatabaseService.shared.fetchNotesForBook(bookIdValue: book.id)) ?? []
            DispatchQueue.main.async {
                notes = loadedNotes
                isLoading = false
            }
        }
    }

    private func addNote(_ note: BookNote) {
        do {
            let noteId = try DatabaseService.shared.insertNote(note)
            var newNote = note
            newNote = BookNote(id: noteId, bookId: note.bookId, text: note.text, pageNumber: note.pageNumber, highlightText: note.highlightText, createdAt: note.createdAt, updatedAt: note.updatedAt)
            notes.insert(newNote, at: 0)
        } catch {
            // Handle error silently
        }
    }

    private func updateNote(_ note: BookNote) {
        do {
            try DatabaseService.shared.updateNote(note)
            if let index = notes.firstIndex(where: { $0.id == note.id }) {
                notes[index] = note
            }
        } catch {
            // Handle error silently
        }
    }

    private func handleDelete() {
        guard let note = noteToDelete else { return }
        do {
            try DatabaseService.shared.deleteNote(id: note.id)
            notes.removeAll { $0.id == note.id }
        } catch {
            // Handle error silently
        }
    }
}

// MARK: - Note Card
struct NoteCard: View {
    let note: BookNote

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            if let highlight = note.highlightText, !highlight.isEmpty {
                Text("\"\(highlight)\"")
                    .font(.system(.caption, design: .serif))
                    .foregroundStyle(DesignTokens.accent)
                    .lineLimit(2)
                    .italic()
                    .padding(.bottom, 2)
            }

            Text(note.text)
                .font(.subheadline)
                .foregroundStyle(DesignTokens.primaryText)
                .textSelection(.enabled)

            HStack {
                if let page = note.pageNumber {
                    HStack(spacing: 4) {
                        Image(systemName: "book.pages")
                            .font(.caption2)
                        Text("Page \(page)")
                            .font(.caption)
                    }
                    .foregroundStyle(DesignTokens.secondaryText)
                }

                Spacer()

                Text(note.updatedAt, style: .date)
                    .font(.caption)
                    .foregroundStyle(DesignTokens.secondaryText)
            }
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(DesignTokens.surface, in: RoundedRectangle(cornerRadius: 12))
        .shadow(color: .black.opacity(0.04), radius: 4, x: 0, y: 2)
    }
}

// MARK: - Note Edit Sheet
struct NoteEditSheet: View {
    let bookId: Int64
    let existingNote: BookNote?
    @Environment(\.dismiss) private var dismiss
    @State private var noteText: String
    @State private var pageNumber: String
    @State private var highlightText: String
    @State private var showingError = false
    @State private var errorMessage = ""

    let onSave: (BookNote) -> Void

    init(bookId: Int64, existingNote: BookNote?, onSave: @escaping (BookNote) -> Void) {
        self.bookId = bookId
        self.existingNote = existingNote
        self.onSave = onSave
        _noteText = State(initialValue: existingNote?.text ?? "")
        _pageNumber = State(initialValue: existingNote?.pageNumber.map { String($0) } ?? "")
        _highlightText = State(initialValue: existingNote?.highlightText ?? "")
    }

    var body: some View {
        NavigationStack {
            ZStack {
                DesignTokens.background
                    .ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 24) {
                        // Highlighted passage
                        if !highlightText.isEmpty || existingNote?.highlightText != nil {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Highlighted Passage")
                                    .font(.caption.weight(.semibold))
                                    .foregroundStyle(DesignTokens.secondaryText)

                                Text(highlightText.isEmpty ? "Paste or type the passage..." : highlightText)
                                    .font(.system(.body, design: .serif))
                                    .foregroundStyle(highlightText.isEmpty ? DesignTokens.secondaryText : DesignTokens.primaryText)
                                    .italic(highlightText.isEmpty)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .padding()
                                    .background(DesignTokens.accent.opacity(0.08))
                                    .clipShape(RoundedRectangle(cornerRadius: 10))
                            }
                        }

                        // Note text
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Your Note")
                                .font(.caption.weight(.semibold))
                                .foregroundStyle(DesignTokens.secondaryText)

                            TextEditor(text: $noteText)
                                .font(.body)
                                .foregroundStyle(DesignTokens.primaryText)
                                .scrollContentBackground(.hidden)
                                .frame(minHeight: 150)
                                .padding(12)
                                .background(DesignTokens.surface, in: RoundedRectangle(cornerRadius: 12))
                        }

                        // Page number
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Page Number (optional)")
                                .font(.caption.weight(.semibold))
                                .foregroundStyle(DesignTokens.secondaryText)

                            TextField("e.g. 42", text: $pageNumber)
                                .font(.body)
                                .keyboardType(.numberPad)
                                .padding()
                                .background(DesignTokens.surface, in: RoundedRectangle(cornerRadius: 12))
                        }

                        // Highlighted passage input
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Highlighted Passage (optional)")
                                .font(.caption.weight(.semibold))
                                .foregroundStyle(DesignTokens.secondaryText)

                            TextEditor(text: $highlightText)
                                .font(.system(.body, design: .serif))
                                .foregroundStyle(DesignTokens.primaryText)
                                .scrollContentBackground(.hidden)
                                .frame(minHeight: 60)
                                .padding(12)
                                .background(DesignTokens.surface, in: RoundedRectangle(cornerRadius: 12))
                        }

                        Spacer()
                    }
                    .padding()
                }
            }
            .navigationTitle(existingNote == nil ? "New Note" : "Edit Note")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                        .foregroundStyle(DesignTokens.secondaryText)
                }
                ToolbarItem(placement: .primaryAction) {
                    Button("Save") { handleSave() }
                        .disabled(noteText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                        .foregroundStyle(DesignTokens.accent)
                }
            }
            .alert("Note Error", isPresented: $showingError) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(errorMessage)
            }
        }
    }

    private func handleSave() {
        let trimmed = noteText.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmed.isEmpty {
            errorMessage = "Note text cannot be empty."
            showingError = true
            return
        }

        let page = Int(pageNumber)
        let highlight = highlightText.trimmingCharacters(in: .whitespacesAndNewlines)

        let note = BookNote(
            id: existingNote?.id ?? 0,
            bookId: bookId,
            text: trimmed,
            pageNumber: page,
            highlightText: highlight.isEmpty ? nil : highlight,
            createdAt: existingNote?.createdAt ?? Date(),
            updatedAt: Date()
        )
        onSave(note)
        dismiss()
    }
}

#Preview {
    BookNotesView(book: Book(title: "The Great Gatsby", author: "F. Scott Fitzgerald"))
}
