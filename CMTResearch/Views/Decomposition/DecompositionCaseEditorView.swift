import SwiftUI
import SwiftData

struct DecompositionCaseEditorView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Query(sort: \ModePassport.name) private var modes: [ModePassport]

    var decompositionCase: DecompositionCase?

    @State private var title: String
    @State private var intentDescription: String
    @State private var domain: String
    @State private var notes: String
    @State private var steps: [EditableStep]

    private struct EditableStep: Identifiable {
        let id = UUID()
        var description: String
        var modeID: PersistentIdentifier?
        var existingStep: DecompositionStep?
    }

    init(decompositionCase: DecompositionCase? = nil) {
        self.decompositionCase = decompositionCase
        _title = State(initialValue: decompositionCase?.title ?? "")
        _intentDescription = State(initialValue: decompositionCase?.intentDescription ?? "")
        _domain = State(initialValue: decompositionCase?.domain ?? "")
        _notes = State(initialValue: decompositionCase?.notes ?? "")
        let existingSteps = (decompositionCase?.orderedSteps ?? []).map {
            EditableStep(description: $0.stepDescription, modeID: $0.mode?.persistentModelID, existingStep: $0)
        }
        _steps = State(initialValue: existingSteps)
    }

    var body: some View {
        Form {
            Section("Task Container") {
                TextField("Title (e.g. Launch Newsletter)", text: $title)
                TextField("Intent — why is this being done?", text: $intentDescription, axis: .vertical)
                TextField("Domain (e.g. Newsletter, School, Personal)", text: $domain)
            }

            Section("Cognitive Pipeline") {
                ForEach($steps) { $step in
                    HStack(alignment: .top) {
                        VStack(alignment: .leading, spacing: 6) {
                            TextField("Step description", text: $step.description)
                            Picker("Mode", selection: $step.modeID) {
                                Text("Unassigned").tag(PersistentIdentifier?.none)
                                ForEach(modes) { mode in
                                    Text(mode.name).tag(Optional(mode.persistentModelID))
                                }
                            }
                            .pickerStyle(.menu)
                        }
                        Button(role: .destructive) {
                            steps.removeAll { $0.id == step.id }
                        } label: {
                            Image(systemName: "minus.circle.fill")
                        }
                        .buttonStyle(.plain)
                    }
                }

                Button {
                    steps.append(EditableStep(description: "", modeID: nil, existingStep: nil))
                } label: {
                    Label("Add Step", systemImage: "plus")
                }
            }

            Section("Notes") {
                TextField("Notes", text: $notes, axis: .vertical)
            }
        }
        .navigationTitle(decompositionCase == nil ? "New Case" : "Edit Case")
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Cancel") { dismiss() }
            }
            ToolbarItem(placement: .confirmationAction) {
                Button("Save", action: save)
                    .disabled(title.trimmingCharacters(in: .whitespaces).isEmpty)
            }
        }
    }

    private func save() {
        let targetCase = decompositionCase ?? DecompositionCase(title: title)
        targetCase.title = title
        targetCase.intentDescription = intentDescription
        targetCase.domain = domain
        targetCase.notes = notes

        if decompositionCase == nil {
            modelContext.insert(targetCase)
        }

        let keptStepIDs = Set(steps.compactMap { $0.existingStep?.persistentModelID })
        for existing in targetCase.steps where !keptStepIDs.contains(existing.persistentModelID) {
            modelContext.delete(existing)
        }

        for (index, editable) in steps.enumerated() {
            let mode = editable.modeID.flatMap { id in modes.first { $0.persistentModelID == id } }
            if let existingStep = editable.existingStep {
                existingStep.order = index
                existingStep.stepDescription = editable.description
                existingStep.mode = mode
            } else {
                let newStep = DecompositionStep(order: index, stepDescription: editable.description, decompositionCase: targetCase, mode: mode)
                modelContext.insert(newStep)
            }
        }

        try? modelContext.save()
        dismiss()
    }
}
