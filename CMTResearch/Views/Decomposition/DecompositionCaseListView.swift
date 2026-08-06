import SwiftUI
import SwiftData

struct DecompositionCaseListView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \DecompositionCase.dateCreated, order: .reverse) private var cases: [DecompositionCase]
    @State private var isPresentingEditor = false

    var body: some View {
        List {
            if cases.isEmpty {
                ContentUnavailableView(
                    "No Decomposition Cases",
                    systemImage: "list.bullet.indent",
                    description: Text("Decompose a real task into its cognitive steps before it can be optimized.")
                )
            } else {
                ForEach(cases) { decompositionCase in
                    NavigationLink {
                        DecompositionCaseDetailView(decompositionCase: decompositionCase)
                    } label: {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(decompositionCase.title).font(.headline)
                            Text("\(decompositionCase.steps.count) step\(decompositionCase.steps.count == 1 ? "" : "s") · \(decompositionCase.domain.isEmpty ? "Unspecified domain" : decompositionCase.domain)")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        .padding(.vertical, 2)
                    }
                }
                .onDelete(perform: delete)
            }
        }
        .navigationTitle("Decomposition Cases")
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button {
                    isPresentingEditor = true
                } label: {
                    Label("New Case", systemImage: "plus")
                }
            }
        }
        .sheet(isPresented: $isPresentingEditor) {
            NavigationStack {
                DecompositionCaseEditorView()
            }
        }
    }

    private func delete(at offsets: IndexSet) {
        for index in offsets {
            modelContext.delete(cases[index])
        }
    }
}
