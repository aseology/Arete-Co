import SwiftUI
import SwiftData

struct GlossaryView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \GlossaryTerm.term) private var terms: [GlossaryTerm]
    @State private var searchText = ""
    @State private var isPresentingNewTerm = false
    @State private var newTerm = ""
    @State private var newDefinition = ""

    private var filteredTerms: [GlossaryTerm] {
        guard !searchText.isEmpty else { return terms }
        return terms.filter {
            $0.term.localizedCaseInsensitiveContains(searchText) ||
            $0.definition.localizedCaseInsensitiveContains(searchText)
        }
    }

    var body: some View {
        List {
            ForEach(filteredTerms) { term in
                VStack(alignment: .leading, spacing: 4) {
                    Text(term.term).font(.headline)
                    Text(term.definition).font(.subheadline).foregroundStyle(.secondary)
                }
                .padding(.vertical, 2)
            }
            .onDelete(perform: delete)
        }
        .searchable(text: $searchText, prompt: "Search glossary")
        .navigationTitle("Glossary")
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button {
                    isPresentingNewTerm = true
                } label: {
                    Label("Add Term", systemImage: "plus")
                }
            }
        }
        .sheet(isPresented: $isPresentingNewTerm) {
            NavigationStack {
                Form {
                    TextField("Term", text: $newTerm)
                    TextField("Definition", text: $newDefinition, axis: .vertical)
                }
                .navigationTitle("New Term")
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Cancel") {
                            newTerm = ""
                            newDefinition = ""
                            isPresentingNewTerm = false
                        }
                    }
                    ToolbarItem(placement: .confirmationAction) {
                        Button("Save") {
                            modelContext.insert(GlossaryTerm(term: newTerm, definition: newDefinition))
                            newTerm = ""
                            newDefinition = ""
                            isPresentingNewTerm = false
                        }
                        .disabled(newTerm.trimmingCharacters(in: .whitespaces).isEmpty)
                    }
                }
            }
        }
    }

    private func delete(at offsets: IndexSet) {
        for index in offsets {
            modelContext.delete(filteredTerms[index])
        }
    }
}
