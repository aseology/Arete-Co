import SwiftUI
import SwiftData

struct EvidenceEntryEditorView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Query(sort: \ModePassport.name) private var modes: [ModePassport]

    var entry: EvidenceEntry?

    @State private var entryDescription: String
    @State private var evidenceType: EvidenceType
    @State private var stance: EvidenceStance
    @State private var source: String
    @State private var relatedModeID: PersistentIdentifier?
    @State private var dateLogged: Date

    init(entry: EvidenceEntry? = nil) {
        self.entry = entry
        _entryDescription = State(initialValue: entry?.entryDescription ?? "")
        _evidenceType = State(initialValue: entry?.evidenceType ?? .observational)
        _stance = State(initialValue: entry?.stance ?? .neutral)
        _source = State(initialValue: entry?.source ?? "")
        _relatedModeID = State(initialValue: entry?.relatedMode?.persistentModelID)
        _dateLogged = State(initialValue: entry?.dateLogged ?? .now)
    }

    var body: some View {
        Form {
            Section("Observation") {
                TextField("What did you observe?", text: $entryDescription, axis: .vertical)
                DatePicker("Date", selection: $dateLogged, displayedComponents: .date)
            }

            Section("Classification") {
                Picker("Evidence Layer", selection: $evidenceType) {
                    ForEach(EvidenceType.allCases) { type in
                        Text(type.rawValue).tag(type)
                    }
                }
                Picker("Stance", selection: $stance) {
                    ForEach(EvidenceStance.allCases) { stanceCase in
                        Text(stanceCase.rawValue).tag(stanceCase)
                    }
                }
                Picker("Related Mode", selection: $relatedModeID) {
                    Text("Unlinked").tag(PersistentIdentifier?.none)
                    ForEach(modes) { mode in
                        Text(mode.name).tag(Optional(mode.persistentModelID))
                    }
                }
            }

            Section("Source") {
                TextField("Citation, link, or context", text: $source, axis: .vertical)
            }
        }
        .navigationTitle(entry == nil ? "Log Evidence" : "Edit Evidence")
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Cancel") { dismiss() }
            }
            ToolbarItem(placement: .confirmationAction) {
                Button("Save", action: save)
                    .disabled(entryDescription.trimmingCharacters(in: .whitespaces).isEmpty)
            }
        }
    }

    private func save() {
        let mode = relatedModeID.flatMap { id in modes.first { $0.persistentModelID == id } }
        if let entry {
            entry.entryDescription = entryDescription
            entry.evidenceType = evidenceType
            entry.stance = stance
            entry.source = source
            entry.relatedMode = mode
            entry.dateLogged = dateLogged
        } else {
            let newEntry = EvidenceEntry(
                dateLogged: dateLogged,
                evidenceType: evidenceType,
                stance: stance,
                entryDescription: entryDescription,
                source: source,
                relatedMode: mode
            )
            modelContext.insert(newEntry)
        }
        try? modelContext.save()
        dismiss()
    }
}
