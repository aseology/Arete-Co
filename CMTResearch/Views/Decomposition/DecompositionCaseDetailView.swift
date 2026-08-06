import SwiftUI
import SwiftData

struct DecompositionCaseDetailView: View {
    @Bindable var decompositionCase: DecompositionCase
    @State private var isPresentingEditor = false

    var body: some View {
        List {
            Section("Intent") {
                Text(decompositionCase.intentDescription.isEmpty ? "No intent recorded." : decompositionCase.intentDescription)
                    .foregroundStyle(decompositionCase.intentDescription.isEmpty ? .secondary : .primary)
                if !decompositionCase.domain.isEmpty {
                    LabeledContent("Domain", value: decompositionCase.domain)
                }
            }

            Section("Cognitive Pipeline") {
                if decompositionCase.orderedSteps.isEmpty {
                    Text("No steps yet. Edit this case to add its cognitive sequence.")
                        .foregroundStyle(.secondary)
                } else {
                    ForEach(Array(decompositionCase.orderedSteps.enumerated()), id: \.element.persistentModelID) { index, step in
                        HStack(alignment: .top, spacing: 10) {
                            Text("\(index + 1)")
                                .font(.caption.bold())
                                .frame(width: 22, height: 22)
                                .background(Circle().fill(AppTheme.background))
                            VStack(alignment: .leading, spacing: 2) {
                                Text(step.stepDescription)
                                if let mode = step.mode {
                                    Text(mode.name)
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                } else {
                                    Text("Unassigned mode")
                                        .font(.caption)
                                        .foregroundStyle(.orange)
                                }
                            }
                        }
                    }
                }
            }

            if !decompositionCase.notes.isEmpty {
                Section("Notes") {
                    Text(decompositionCase.notes)
                }
            }
        }
        .navigationTitle(decompositionCase.title)
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button("Edit") { isPresentingEditor = true }
            }
        }
        .sheet(isPresented: $isPresentingEditor) {
            NavigationStack {
                DecompositionCaseEditorView(decompositionCase: decompositionCase)
            }
        }
    }
}
