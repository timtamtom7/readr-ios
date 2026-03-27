import SwiftUI

// MARK: - Tag Pill View
struct TagPillView: View {
    let tag: Tag
    var isSelected: Bool = false
    var showRemoveButton: Bool = false
    var onTap: (() -> Void)?
    var onRemove: (() -> Void)?

    var body: some View {
        HStack(spacing: 4) {
            Text(tag.name)
                .font(.caption.weight(.medium))
                .foregroundStyle(isSelected ? .white : tag.color)

            if showRemoveButton {
                Button {
                    Theme.Haptics.light()
                    onRemove?()
                } label: {
                    Image(systemName: "xmark")
                        .font(.system(size: 11, weight: .bold))
                        .foregroundStyle(isSelected ? .white.opacity(0.8) : tag.color.opacity(0.8))
                }
                .accessibilityLabel("Remove tag \(tag.name)")
            }
        }
        .padding(.horizontal, showRemoveButton ? 10 : 12)
        .padding(.vertical, 6)
        .background(
            Capsule()
                .fill(isSelected ? tag.color : tag.color.opacity(0.12))
        )
        .contentShape(Capsule())
        .onTapGesture {
            Theme.Haptics.selection()
            onTap?()
        }
    }
}

// MARK: - Tag Management Row
struct TagManagementRow: View {
    let tag: Tag
    let quoteCount: Int
    var onTap: () -> Void
    var onEdit: () -> Void
    var onDelete: () -> Void

    var body: some View {
        HStack(spacing: 14) {
            Circle()
                .fill(tag.color)
                .frame(width: 12, height: 12)

            Text(tag.name)
                .font(.subheadline.weight(.medium))
                .foregroundStyle(DesignTokens.primaryText)

            Spacer()

            Text("\(quoteCount) quote\(quoteCount == 1 ? "" : "s")")
                .font(.caption)
                .foregroundStyle(DesignTokens.secondaryText)

            Button(action: onTap) {
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundStyle(DesignTokens.secondaryText.opacity(0.5))
            }
        }
        .padding(14)
        .background(DesignTokens.surface, in: RoundedRectangle(cornerRadius: 12))
        .contentShape(RoundedRectangle(cornerRadius: 12))
        .onTapGesture(perform: onTap)
        .contextMenu {
            Button(action: onEdit) {
                Label("Edit", systemImage: "pencil")
            }
            Button(role: .destructive, action: onDelete) {
                Label("Delete", systemImage: "trash")
            }
        }
    }
}

// MARK: - Tag Filter Row
struct TagFilterRow: View {
    let tag: Tag
    let count: Int
    let isSelected: Bool

    var body: some View {
        HStack(spacing: 14) {
            Circle()
                .fill(tag.color)
                .frame(width: 12, height: 12)

            Text(tag.name)
                .font(.subheadline.weight(.medium))
                .foregroundStyle(DesignTokens.primaryText)

            Spacer()

            Text("\(count) quote\(count == 1 ? "" : "s")")
                .font(.caption)
                .foregroundStyle(DesignTokens.secondaryText)

            Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                .foregroundStyle(isSelected ? DesignTokens.accent : DesignTokens.secondaryText.opacity(0.4))
        }
        .padding(14)
        .background(DesignTokens.surface, in: RoundedRectangle(cornerRadius: 12))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(isSelected ? tag.color.opacity(0.4) : Color.clear, lineWidth: 1)
        )
    }
}

// MARK: - Tag Create Sheet
struct TagCreateSheet: View {
    @Environment(\.dismiss) private var dismiss
    @State private var tagName = ""
    @State private var selectedColorHex = "c87b4f"
    @State private var showingError = false
    @State private var errorMessage = ""

    let onSave: (String, String) -> Void

    private let colorOptions = [
        "c87b4f", "7b6b8a", "5a7a6a", "8b4a4a", "4a6b8b",
        "d4943a", "6b5a7b", "3a7a6b", "8b6b4a", "4a8b7b"
    ]

    var body: some View {
        NavigationStack {
            ZStack {
                DesignTokens.background
                    .ignoresSafeArea()

                VStack(spacing: 28) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Tag Name")
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(DesignTokens.primaryText)

                        TextField("e.g. Inspiration, Wisdom, Funny...", text: $tagName)
                            .font(.body)
                            .padding()
                            .background(DesignTokens.surface, in: RoundedRectangle(cornerRadius: 12))
                    }

                    VStack(alignment: .leading, spacing: 12) {
                        Text("Color")
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(DesignTokens.primaryText)

                        colorGrid
                    }

                    previewSection

                    Spacer()
                }
                .padding()
            }
            .navigationTitle("New Tag")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                        .foregroundStyle(DesignTokens.secondaryText)
                }
                ToolbarItem(placement: .primaryAction) {
                    Button("Create") { handleCreate() }
                        .disabled(tagName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                        .foregroundStyle(DesignTokens.accent)
                }
            }
            .alert("Tag Error", isPresented: $showingError) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(errorMessage)
            }
        }
        .presentationDetents([.medium])
    }

    private var colorGrid: some View {
        LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 5), spacing: 12) {
            ForEach(colorOptions, id: \.self) { hex in
                Circle()
                    .fill(Color(hex: hex))
                    .frame(width: 44, height: 44)
                    .overlay(
                        Circle()
                            .stroke(Color.white, lineWidth: selectedColorHex == hex ? 3 : 0)
                    )
                    .onTapGesture {
                        selectedColorHex = hex
                    }
            }
        }
    }

    private var previewSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Preview")
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(DesignTokens.primaryText)

            HStack {
                if !tagName.isEmpty {
                    TagPillView(tag: Tag(name: tagName, colorHex: selectedColorHex))
                } else {
                    Text("Enter a name to preview")
                        .font(.caption)
                        .foregroundStyle(DesignTokens.secondaryText)
                }
                Spacer()
            }
        }
    }

    private func handleCreate() {
        let trimmed = tagName.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmed.isEmpty {
            errorMessage = "Tag name cannot be empty."
            showingError = true
            return
        }
        onSave(trimmed, selectedColorHex)
        dismiss()
    }
}

// MARK: - Tag Edit Sheet
struct TagEditSheet: View {
    let tag: Tag
    @Environment(\.dismiss) private var dismiss
    @State private var tagName: String
    @State private var selectedColorHex: String
    @State private var showingError = false
    @State private var errorMessage = ""

    let onSave: (String, String) -> Void

    private let colorOptions = [
        "c87b4f", "7b6b8a", "5a7a6a", "8b4a4a", "4a6b8b",
        "d4943a", "6b5a7b", "3a7a6b", "8b6b4a", "4a8b7b"
    ]

    init(tag: Tag, onSave: @escaping (String, String) -> Void) {
        self.tag = tag
        self.onSave = onSave
        _tagName = State(initialValue: tag.name)
        _selectedColorHex = State(initialValue: tag.colorHex)
    }

    var body: some View {
        NavigationStack {
            ZStack {
                DesignTokens.background
                    .ignoresSafeArea()

                VStack(spacing: 28) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Tag Name")
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(DesignTokens.primaryText)

                        TextField("Tag name", text: $tagName)
                            .font(.body)
                            .padding()
                            .background(DesignTokens.surface, in: RoundedRectangle(cornerRadius: 12))
                    }

                    VStack(alignment: .leading, spacing: 12) {
                        Text("Color")
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(DesignTokens.primaryText)

                        editColorGrid
                    }

                    VStack(alignment: .leading, spacing: 8) {
                        Text("Preview")
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(DesignTokens.primaryText)

                        HStack {
                            if !tagName.isEmpty {
                                TagPillView(tag: Tag(name: tagName, colorHex: selectedColorHex))
                            } else {
                                Text("Enter a name to preview")
                                    .font(.caption)
                                    .foregroundStyle(DesignTokens.secondaryText)
                            }
                            Spacer()
                        }
                    }

                    Spacer()
                }
                .padding()
            }
            .navigationTitle("Edit Tag")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                        .foregroundStyle(DesignTokens.secondaryText)
                }
                ToolbarItem(placement: .primaryAction) {
                    Button("Save") { handleSave() }
                        .disabled(tagName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                        .foregroundStyle(DesignTokens.accent)
                }
            }
            .alert("Tag Error", isPresented: $showingError) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(errorMessage)
            }
        }
        .presentationDetents([.medium])
    }

    private var editColorGrid: some View {
        LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 5), spacing: 12) {
            ForEach(colorOptions, id: \.self) { hex in
                Circle()
                    .fill(Color(hex: hex))
                    .frame(width: 44, height: 44)
                    .overlay(
                        Circle()
                            .stroke(Color.white, lineWidth: selectedColorHex == hex ? 3 : 0)
                    )
                    .onTapGesture {
                        selectedColorHex = hex
                    }
            }
        }
    }

    private func handleSave() {
        let trimmed = tagName.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmed.isEmpty {
            errorMessage = "Tag name cannot be empty."
            showingError = true
            return
        }
        onSave(trimmed, selectedColorHex)
        dismiss()
    }
}

// MARK: - Tag Filter View
struct TagFilterView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var allTags: [(Tag, Int)] = []
    @State private var selectedTagIds: Set<Int64> = []
    @State private var isLoading = true

    let onApply: (Set<Int64>) -> Void

    var body: some View {
        NavigationStack {
            ZStack {
                DesignTokens.background
                    .ignoresSafeArea()

                if isLoading {
                    ProgressView()
                        .tint(DesignTokens.accent)
                } else if allTags.isEmpty {
                    emptyTagsState
                } else {
                    filterList
                }
            }
            .navigationTitle("Filter by Tag")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button { dismiss() } label: {
                        Image(systemName: "xmark")
                            .foregroundStyle(DesignTokens.secondaryText)
                    }
                }
                ToolbarItem(placement: .primaryAction) {
                    Button("Apply") {
                        onApply(selectedTagIds)
                        dismiss()
                    }
                    .foregroundStyle(DesignTokens.accent)
                }
            }
        }
        .onAppear { loadTags() }
    }

    private var filterList: some View {
        ScrollView {
            LazyVStack(spacing: 10) {
                ForEach(allTags, id: \.0.id) { item in
                    let (tag, count) = item
                    TagFilterRow(tag: tag, count: count, isSelected: selectedTagIds.contains(tag.id))
                        .onTapGesture {
                            if selectedTagIds.contains(tag.id) {
                                selectedTagIds.remove(tag.id)
                            } else {
                                selectedTagIds.insert(tag.id)
                            }
                        }
                }
            }
            .padding()
        }
    }

    private var emptyTagsState: some View {
        VStack(spacing: 16) {
            Image(systemName: "tag")
                .font(.system(size: 40))
                .foregroundStyle(DesignTokens.secondaryText.opacity(0.4))

            Text("No tags yet")
                .font(.headline)
                .foregroundStyle(DesignTokens.primaryText)

            Text("Add tags to your quotes to filter them here.")
                .font(.subheadline)
                .foregroundStyle(DesignTokens.secondaryText)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)
        }
        .padding()
    }

    private func loadTags() {
        isLoading = true
        DispatchQueue.global(qos: .userInitiated).async {
            let result = (try? DatabaseService.shared.fetchAllTagsWithCounts()) ?? []
            DispatchQueue.main.async {
                allTags = result
                isLoading = false
            }
        }
    }
}

// MARK: - Tag Management View
struct TagManagementView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var allTags: [(Tag, Int)] = []
    @State private var isLoading = true
    @State private var showingCreateSheet = false
    @State private var tagToEdit: Tag?
    @State private var showingDeleteConfirmation = false
    @State private var tagToDelete: Tag?
    @State private var showingError = false
    @State private var errorMessage = ""

    var body: some View {
        NavigationStack {
            ZStack {
                DesignTokens.background
                    .ignoresSafeArea()

                if isLoading {
                    ProgressView()
                        .tint(DesignTokens.accent)
                } else if allTags.isEmpty {
                    emptyTagsState
                } else {
                    managementList
                }
            }
            .navigationTitle("Manage Tags")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button { dismiss() } label: {
                        Image(systemName: "xmark")
                            .foregroundStyle(DesignTokens.secondaryText)
                    }
                }
                ToolbarItem(placement: .primaryAction) {
                    Button { showingCreateSheet = true } label: {
                        Image(systemName: "plus.circle.fill")
                            .font(.title2)
                            .foregroundStyle(DesignTokens.accent)
                    }
                }
            }
            .sheet(isPresented: $showingCreateSheet) {
                TagCreateSheet { name, colorHex in
                    createTag(name: name, colorHex: colorHex)
                }
            }
            .sheet(item: $tagToEdit) { tag in
                TagEditSheet(tag: tag) { name, colorHex in
                    updateTag(Tag(id: tag.id, name: name, colorHex: colorHex))
                }
            }
            .alert("Delete Tag?", isPresented: $showingDeleteConfirmation) {
                Button("Cancel", role: .cancel) {}
                Button("Delete", role: .destructive) { handleDelete() }
            } message: {
                if let tag = tagToDelete {
                    Text("This will remove \"\(tag.name)\" from all quotes. This cannot be undone.")
                }
            }
            .alert("Tag Error", isPresented: $showingError) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(errorMessage)
            }
        }
        .onAppear { loadTags() }
    }

    private var managementList: some View {
        ScrollView {
            LazyVStack(spacing: 10) {
                ForEach(allTags, id: \.0.id) { item in
                    let (tag, count) = item
                    TagManagementRow(
                        tag: tag,
                        quoteCount: count,
                        onTap: { tagToEdit = tag },
                        onEdit: { tagToEdit = tag },
                        onDelete: { confirmDelete(tag) }
                    )
                }
            }
            .padding()
        }
    }

    private var emptyTagsState: some View {
        VStack(spacing: 20) {
            ZStack {
                Circle()
                    .fill(DesignTokens.accent.opacity(0.08))
                    .frame(width: 100, height: 100)

                Image(systemName: "tag")
                    .font(.system(size: 36))
                    .foregroundStyle(DesignTokens.accent.opacity(0.5))
            }

            Text("No tags yet")
                .font(.headline)
                .foregroundStyle(DesignTokens.primaryText)

            Text("Create tags to organize your quotes.")
                .font(.subheadline)
                .foregroundStyle(DesignTokens.secondaryText)

            Button {
                showingCreateSheet = true
            } label: {
                HStack {
                    Image(systemName: "plus")
                    Text("Create First Tag")
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

    private func loadTags() {
        isLoading = true
        DispatchQueue.global(qos: .userInitiated).async {
            let result = (try? DatabaseService.shared.fetchAllTagsWithCounts()) ?? []
            DispatchQueue.main.async {
                allTags = result
                isLoading = false
            }
        }
    }

    private func createTag(name: String, colorHex: String) {
        do {
            try DatabaseService.shared.insertTag(Tag(name: name, colorHex: colorHex))
            loadTags()
        } catch {
            errorMessage = "Failed to create tag. Please try again."
            showingError = true
        }
    }

    private func updateTag(_ tag: Tag) {
        do {
            try DatabaseService.shared.updateTag(tag)
            loadTags()
        } catch {
            errorMessage = "Failed to update tag. Please try again."
            showingError = true
        }
    }

    private func confirmDelete(_ tag: Tag) {
        tagToDelete = tag
        showingDeleteConfirmation = true
    }

    private func handleDelete() {
        guard let tag = tagToDelete else { return }
        do {
            try DatabaseService.shared.deleteTag(id: tag.id)
            loadTags()
        } catch {
            errorMessage = "Failed to delete tag. Please try again."
            showingError = true
        }
    }
}

// MARK: - Quote Tag Editor
struct QuoteTagEditorView: View {
    let quoteId: Int64
    @State private var quoteTags: [Tag] = []
    @State private var allTags: [Tag] = []
    @State private var isLoading = true
    @State private var showingCreateSheet = false
    @State private var showingError = false
    @State private var errorMessage = ""

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            headerRow

            if isLoading {
                ProgressView()
                    .frame(maxWidth: .infinity)
            } else if quoteTags.isEmpty {
                Text("No tags yet — tap + to add")
                    .font(.caption)
                    .foregroundStyle(DesignTokens.secondaryText)
            } else {
                tagPills
            }

            if !availableTags.isEmpty {
                Divider()
                Text("Add from existing")
                    .font(.caption)
                    .foregroundStyle(DesignTokens.secondaryText)
                availableTagPills
            }
        }
        .sheet(isPresented: $showingCreateSheet) {
            TagCreateSheet { name, colorHex in
                createAndAddTag(name: name, colorHex: colorHex)
            }
        }
        .alert("Tag Error", isPresented: $showingError) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(errorMessage)
        }
        .onAppear { loadTags() }
    }

    private var headerRow: some View {
        HStack {
            Text("Tags")
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(DesignTokens.primaryText)

            Spacer()

            Button {
                showingCreateSheet = true
            } label: {
                Image(systemName: "plus.circle")
                    .font(.caption)
                    .foregroundStyle(DesignTokens.accent)
            }
        }
    }

    private var tagPills: some View {
        FlowLayout(spacing: 8) {
            ForEach(quoteTags) { tag in
                TagPillView(tag: tag, showRemoveButton: true) {
                    removeTag(tag)
                }
            }
        }
    }

    private var availableTagPills: some View {
        FlowLayout(spacing: 8) {
            ForEach(availableTags) { tag in
                TagPillView(tag: tag) {
                    addTag(tag)
                }
            }
        }
    }

    private var availableTags: [Tag] {
        let quoteTagIds = Set(quoteTags.map { $0.id })
        return allTags.filter { !quoteTagIds.contains($0.id) }
    }

    private func loadTags() {
        isLoading = true
        DispatchQueue.global(qos: .userInitiated).async {
            do {
                let qt = try DatabaseService.shared.fetchTagsForQuote(quoteIdValue: quoteId)
                let at = try DatabaseService.shared.fetchAllTags()
                DispatchQueue.main.async {
                    quoteTags = qt
                    allTags = at
                    isLoading = false
                }
            } catch {
                DispatchQueue.main.async {
                    isLoading = false
                }
            }
        }
    }

    private func addTag(_ tag: Tag) {
        do {
            try DatabaseService.shared.addTagToQuote(quoteIdValue: quoteId, tagIdValue: tag.id)
            quoteTags.append(tag)
        } catch {
            errorMessage = "Failed to add tag. Please try again."
            showingError = true
        }
    }

    private func removeTag(_ tag: Tag) {
        do {
            try DatabaseService.shared.removeTagFromQuote(quoteIdValue: quoteId, tagIdValue: tag.id)
            quoteTags.removeAll { $0.id == tag.id }
        } catch {
            errorMessage = "Failed to remove tag. Please try again."
            showingError = true
        }
    }

    private func createAndAddTag(name: String, colorHex: String) {
        do {
            let tagId = try DatabaseService.shared.insertTag(Tag(name: name, colorHex: colorHex))
            try DatabaseService.shared.addTagToQuote(quoteIdValue: quoteId, tagIdValue: tagId)
            let newTag = Tag(id: tagId, name: name, colorHex: colorHex)
            quoteTags.append(newTag)
            allTags.append(newTag)
        } catch {
            errorMessage = "Failed to create tag. Please try again."
            showingError = true
        }
    }
}

// MARK: - Flow Layout
struct FlowLayout: Layout {
    var spacing: CGFloat = 8

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let result = layout(proposal.width ?? 0, subviews: subviews)
        return CGSize(width: proposal.width ?? 0, height: result.height)
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let result = layout(bounds.width, subviews: subviews)
        for (index, frame) in result.frames.enumerated() {
            subviews[index].place(at: CGPoint(x: frame.minX, y: frame.minY), proposal: .init(frame.size))
        }
    }

    private func layout(_ width: CGFloat, subviews: Subviews) -> (height: CGFloat, frames: [CGRect]) {
        var frames: [CGRect] = []
        var x: CGFloat = 0
        var y: CGFloat = 0
        var rowHeight: CGFloat = 0

        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)
            if x + size.width > width, x > 0 {
                x = 0
                y += rowHeight + spacing
                rowHeight = 0
            }
            frames.append(CGRect(origin: CGPoint(x: x, y: y), size: size))
            x += size.width + spacing
            rowHeight = max(rowHeight, size.height)
        }
        y += rowHeight
        return (y, frames)
    }
}

#Preview {
    TagPillView(tag: Tag(name: "Inspiration", colorHex: "c87b4f"))
        .padding()
}
