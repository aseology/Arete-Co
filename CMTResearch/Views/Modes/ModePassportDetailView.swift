import SwiftUI
import SwiftData

struct ModePassportDetailView: View {
    @Bindable var mode: ModePassport

    @State private var newBehavioralExample = ""
    @State private var newOccupationalExample = ""
    @State private var newEcologicalSupport = ""
    @State private var newQuestion = ""

    var body: some View {
        Form {
            Section("Definition") {
                if !mode.workingDefinition.isEmpty {
                    Text(mode.workingDefinition)
                }
                if !mode.canonicalQuestion.isEmpty {
                    LabeledContent("Canonical Question", value: mode.canonicalQuestion)
                }
                if !mode.primaryCognitiveOperation.isEmpty {
                    LabeledContent("Primary Operation", value: mode.primaryCognitiveOperation)
                }
                if !mode.proposedTransformation.isEmpty {
                    LabeledContent("Transformation", value: mode.proposedTransformation)
                }
            }

            Section("Validation Status") {
                Picker("Status", selection: $mode.validationStatus) {
                    ForEach(ValidationStatus.allCases) { status in
                        Text(status.rawValue).tag(status)
                    }
                }
                .pickerStyle(.segmented)
            }

            Section("Cognitive Cost Profile") {
                costStepper(title: "Entry Cost", value: $mode.entryCost)
                costStepper(title: "Maintenance Cost", value: $mode.maintenanceCost)
                costStepper(title: "Exit Cost", value: $mode.exitCost)
            }

            Section("Behavioral Examples (\(mode.behavioralExamples.count))") {
                ForEach(mode.behavioralExamples, id: \.self) { Text($0) }
                addRow(text: $newBehavioralExample, placeholder: "Add behavioral example") {
                    mode.behavioralExamples.append(newBehavioralExample)
                    newBehavioralExample = ""
                }
            }

            Section("Occupational Examples (\(mode.occupationalExamples.count))") {
                ForEach(mode.occupationalExamples, id: \.self) { Text($0) }
                addRow(text: $newOccupationalExample, placeholder: "Add occupational example") {
                    mode.occupationalExamples.append(newOccupationalExample)
                    newOccupationalExample = ""
                }
            }

            Section("Ecological Signature (\(mode.ecologicalSupports.count))") {
                ForEach(mode.ecologicalSupports, id: \.self) { Text($0) }
                addRow(text: $newEcologicalSupport, placeholder: "Add environmental support") {
                    mode.ecologicalSupports.append(newEcologicalSupport)
                    newEcologicalSupport = ""
                }
            }

            Section("Evidence (\(mode.evidenceEntries.count))") {
                if mode.evidenceEntries.isEmpty {
                    Text("No evidence logged for this mode yet.").foregroundStyle(.secondary)
                } else {
                    ForEach(mode.evidenceEntries.sorted { $0.dateLogged > $1.dateLogged }) { entry in
                        VStack(alignment: .leading, spacing: 2) {
                            Text(entry.entryDescription).lineLimit(2)
                            Text(entry.evidenceType.rawValue)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
            }

            Section("Open Research Questions (\(mode.openResearchQuestions.count))") {
                ForEach(mode.openResearchQuestions, id: \.self) { Text($0) }
                addRow(text: $newQuestion, placeholder: "Add open question") {
                    mode.openResearchQuestions.append(newQuestion)
                    newQuestion = ""
                }
            }

            Section("Revision Notes") {
                TextEditor(text: $mode.revisionNotes)
                    .frame(minHeight: 80)
            }
        }
        .navigationTitle(mode.name)
        .onChange(of: mode.validationStatus) {
            mode.dateUpdated = .now
        }
    }

    private func costStepper(title: String, value: Binding<Int>) -> some View {
        Stepper(value: value, in: 1...5) {
            HStack {
                Text(title)
                Spacer()
                Text("\(value.wrappedValue)/5").foregroundStyle(.secondary)
            }
        }
    }

    private func addRow(text: Binding<String>, placeholder: String, onAdd: @escaping () -> Void) -> some View {
        HStack {
            TextField(placeholder, text: text)
            Button("Add", action: onAdd)
                .disabled(text.wrappedValue.trimmingCharacters(in: .whitespaces).isEmpty)
        }
    }
}
