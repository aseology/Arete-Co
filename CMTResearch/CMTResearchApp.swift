import SwiftUI
import SwiftData

@main
struct CMTResearchApp: App {
    let sharedModelContainer: ModelContainer = {
        let schema = Schema([
            ModePassport.self,
            DecompositionCase.self,
            DecompositionStep.self,
            EvidenceEntry.self,
            GlossaryTerm.self,
            OpenQuestion.self,
            ResearchPlanItem.self,
        ])
        let configuration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
        do {
            return try ModelContainer(for: schema, configurations: [configuration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            RootView()
        }
        .modelContainer(sharedModelContainer)
    }
}

enum AppSection: String, CaseIterable, Identifiable, Hashable {
    case dashboard = "Dashboard"
    case modes = "Mode Passports"
    case decomposition = "Decomposition Cases"
    case evidence = "Evidence Log"
    case researchPlan = "Research Plan"
    case glossary = "Glossary"
    case openQuestions = "Open Questions"

    var id: String { rawValue }

    var systemImage: String {
        switch self {
        case .dashboard: return "square.grid.2x2"
        case .modes: return "brain.head.profile"
        case .decomposition: return "list.bullet.indent"
        case .evidence: return "doc.text.magnifyingglass"
        case .researchPlan: return "checklist"
        case .glossary: return "book"
        case .openQuestions: return "questionmark.circle"
        }
    }
}

struct RootView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var selection: AppSection? = .dashboard

    var body: some View {
        NavigationSplitView {
            List(AppSection.allCases, selection: $selection) { section in
                Label(section.rawValue, systemImage: section.systemImage)
                    .tag(section)
            }
            .navigationTitle("CMT Research")
        } detail: {
            NavigationStack {
                destinationView(for: selection ?? .dashboard)
            }
            .id(selection)
        }
        .task {
            SeedData.populateIfNeeded(context: modelContext)
        }
    }

    @ViewBuilder
    private func destinationView(for section: AppSection) -> some View {
        switch section {
        case .dashboard: DashboardView()
        case .modes: ModePassportListView()
        case .decomposition: DecompositionCaseListView()
        case .evidence: EvidenceLogView()
        case .researchPlan: ResearchPlanView()
        case .glossary: GlossaryView()
        case .openQuestions: OpenQuestionsView()
        }
    }
}
