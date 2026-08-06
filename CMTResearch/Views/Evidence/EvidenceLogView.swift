import SwiftUI
import SwiftData

struct EvidenceLogView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \EvidenceEntry.dateLogged, order: .reverse) private var entries: [EvidenceEntry]
    @State private var isPresentingEditor = false
    @State private var filterType: EvidenceType?

    private var filteredEntries: [EvidenceEntry] {
        guard let filterType else { return entries }
        return entries.filter { $0.evidenceType == filterType }
    }

    var body: some View {
        List {
            if filteredEntries.isEmpty {
                ContentUnavailableView(
                    "No Evidence Logged",
                    systemImage: "doc.text.magnifyingglass",
                    description: Text("Every observation should be captured before it enters the theory.")
                )
            } else {
                ForEach(filteredEntries) { entry in
                    NavigationLink {
                        EvidenceEntryDetailView(entry: entry)
                    } label: {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(entry.entryDescription).lineLimit(2)
                            HStack(spacing: 6) {
                                Circle()
                                    .fill(AppTheme.stanceColor(entry.stance))
                                    .frame(width: 6, height: 6)
                                Text(entry.evidenceType.rawValue)
                                if let mode = entry.relatedMode {
                                    Text("· \(mode.name)")
                                }
                            }
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        }
                        .padding(.vertical, 2)
                    }
                }
                .onDelete(perform: delete)
            }
        }
        .navigationTitle("Evidence Log")
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button {
                    isPresentingEditor = true
                } label: {
                    Label("Log Evidence", systemImage: "plus")
                }
            }
            ToolbarItem(placement: .secondaryAction) {
                Menu {
                    Button("All Types") { filterType = nil }
                    ForEach(EvidenceType.allCases) { type in
                        Button(type.rawValue) { filterType = type }
                    }
                } label: {
                    Label("Filter", systemImage: "line.3.horizontal.decrease.circle")
                }
            }
        }
        .sheet(isPresented: $isPresentingEditor) {
            NavigationStack {
                EvidenceEntryEditorView()
            }
        }
    }

    private func delete(at offsets: IndexSet) {
        for index in offsets {
            modelContext.delete(filteredEntries[index])
        }
    }
}
