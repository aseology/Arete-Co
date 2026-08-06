import SwiftUI
import SwiftData

struct ResearchPlanView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \ResearchPlanItem.order) private var items: [ResearchPlanItem]
    @State private var newItemTitle = ""

    var body: some View {
        List {
            Section("Stabilization Plan") {
                if items.isEmpty {
                    Text("No research plan items yet.").foregroundStyle(.secondary)
                } else {
                    ForEach(items) { item in
                        Button {
                            item.isComplete.toggle()
                        } label: {
                            HStack(alignment: .top) {
                                Image(systemName: item.isComplete ? "checkmark.circle.fill" : "circle")
                                    .foregroundStyle(item.isComplete ? .green : .secondary)
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(item.title)
                                        .strikethrough(item.isComplete)
                                        .foregroundStyle(item.isComplete ? .secondary : .primary)
                                    if !item.detail.isEmpty {
                                        Text(item.detail)
                                            .font(.caption)
                                            .foregroundStyle(.secondary)
                                    }
                                }
                            }
                        }
                        .buttonStyle(.plain)
                    }
                    .onDelete(perform: delete)
                }
            }

            Section("Add Item") {
                HStack {
                    TextField("New research task", text: $newItemTitle)
                    Button("Add") {
                        let nextOrder = (items.map(\.order).max() ?? -1) + 1
                        modelContext.insert(ResearchPlanItem(title: newItemTitle, order: nextOrder))
                        newItemTitle = ""
                    }
                    .disabled(newItemTitle.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
        }
        .navigationTitle("Research Plan")
    }

    private func delete(at offsets: IndexSet) {
        for index in offsets {
            modelContext.delete(items[index])
        }
    }
}
