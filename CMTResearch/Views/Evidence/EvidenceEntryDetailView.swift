import SwiftUI
import SwiftData

struct EvidenceEntryDetailView: View {
    @Bindable var entry: EvidenceEntry
    @State private var isPresentingEditor = false

    var body: some View {
        List {
            Section("Observation") {
                Text(entry.entryDescription)
                LabeledContent("Date", value: entry.dateLogged.formatted(date: .abbreviated, time: .omitted))
            }
            Section("Classification") {
                LabeledContent("Evidence Layer", value: entry.evidenceType.rawValue)
                LabeledContent("Stance", value: entry.stance.rawValue)
                LabeledContent("Related Mode", value: entry.relatedMode?.name ?? "Unlinked")
            }
            if !entry.source.isEmpty {
                Section("Source") {
                    Text(entry.source)
                }
            }
        }
        .navigationTitle("Evidence")
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button("Edit") { isPresentingEditor = true }
            }
        }
        .sheet(isPresented: $isPresentingEditor) {
            NavigationStack {
                EvidenceEntryEditorView(entry: entry)
            }
        }
    }
}
