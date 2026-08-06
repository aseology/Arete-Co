import SwiftUI
import SwiftData

struct OpenQuestionsView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \OpenQuestion.dateCreated, order: .reverse) private var questions: [OpenQuestion]
    @Query(sort: \ModePassport.name) private var modes: [ModePassport]
    @State private var newQuestionText = ""
    @State private var newQuestionModeID: PersistentIdentifier?
    @State private var showResolved = false

    private var visibleQuestions: [OpenQuestion] {
        showResolved ? questions : questions.filter { !$0.isResolved }
    }

    var body: some View {
        List {
            Section {
                if visibleQuestions.isEmpty {
                    Text("No open questions.").foregroundStyle(.secondary)
                } else {
                    ForEach(visibleQuestions) { question in
                        Button {
                            question.isResolved.toggle()
                        } label: {
                            HStack(alignment: .top) {
                                Image(systemName: question.isResolved ? "checkmark.circle.fill" : "circle")
                                    .foregroundStyle(question.isResolved ? .green : .secondary)
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(question.questionText)
                                        .strikethrough(question.isResolved)
                                        .foregroundStyle(question.isResolved ? .secondary : .primary)
                                    if let mode = question.relatedMode {
                                        Text(mode.name).font(.caption).foregroundStyle(.secondary)
                                    }
                                }
                            }
                        }
                        .buttonStyle(.plain)
                    }
                    .onDelete(perform: delete)
                }
            } header: {
                Toggle("Show Resolved", isOn: $showResolved)
            }

            Section("Add Question") {
                TextField("New open question", text: $newQuestionText, axis: .vertical)
                Picker("Related Mode", selection: $newQuestionModeID) {
                    Text("Unlinked").tag(PersistentIdentifier?.none)
                    ForEach(modes) { mode in
                        Text(mode.name).tag(Optional(mode.persistentModelID))
                    }
                }
                Button("Add") {
                    let mode = newQuestionModeID.flatMap { id in modes.first { $0.persistentModelID == id } }
                    modelContext.insert(OpenQuestion(questionText: newQuestionText, relatedMode: mode))
                    newQuestionText = ""
                    newQuestionModeID = nil
                }
                .disabled(newQuestionText.trimmingCharacters(in: .whitespaces).isEmpty)
            }
        }
        .navigationTitle("Open Questions")
    }

    private func delete(at offsets: IndexSet) {
        for index in offsets {
            modelContext.delete(visibleQuestions[index])
        }
    }
}
