import SwiftUI
import SwiftData

struct DashboardView: View {
    @Query private var modes: [ModePassport]
    @Query private var cases: [DecompositionCase]
    @Query private var evidence: [EvidenceEntry]
    @Query(filter: #Predicate<OpenQuestion> { !$0.isResolved }) private var openQuestions: [OpenQuestion]
    @Query(filter: #Predicate<ResearchPlanItem> { !$0.isComplete }) private var openPlanItems: [ResearchPlanItem]

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: AppTheme.Spacing.large) {
                statusSummary
                recentEvidence
                nextSteps
            }
            .padding()
        }
        .navigationTitle("Dashboard")
    }

    private var statusSummary: some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.medium) {
            Text("Taxonomy Status").font(AppTheme.Typography.sectionHeader)

            HStack(spacing: AppTheme.Spacing.medium) {
                statTile(title: "Modes", value: "\(modes.count)")
                statTile(title: "Cases", value: "\(cases.count)")
                statTile(title: "Evidence", value: "\(evidence.count)")
                statTile(title: "Open Qs", value: "\(openQuestions.count)")
            }

            ForEach(ValidationStatus.allCases) { status in
                let count = modes.filter { $0.validationStatus == status }.count
                if count > 0 {
                    HStack {
                        Circle().fill(AppTheme.statusColor(status)).frame(width: 8, height: 8)
                        Text(status.rawValue)
                        Spacer()
                        Text("\(count)").foregroundStyle(.secondary)
                    }
                }
            }
        }
        .padding()
        .background(AppTheme.cardBackground, in: RoundedRectangle(cornerRadius: 12))
    }

    private func statTile(title: String, value: String) -> some View {
        VStack {
            Text(value).font(.title2.bold())
            Text(title).font(.caption).foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 8)
        .background(AppTheme.background, in: RoundedRectangle(cornerRadius: 8))
    }

    private var recentEvidence: some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.medium) {
            Text("Recent Evidence").font(AppTheme.Typography.sectionHeader)
            if evidence.isEmpty {
                Text("No evidence logged yet.").foregroundStyle(.secondary)
            } else {
                ForEach(evidence.sorted { $0.dateLogged > $1.dateLogged }.prefix(3)) { entry in
                    VStack(alignment: .leading, spacing: 2) {
                        Text(entry.entryDescription).lineLimit(2)
                        Text("\(entry.evidenceType.rawValue) · \(entry.relatedMode?.name ?? "Unlinked")")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    .padding(.vertical, 4)
                }
            }
        }
        .padding()
        .background(AppTheme.cardBackground, in: RoundedRectangle(cornerRadius: 12))
    }

    private var nextSteps: some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.medium) {
            Text("Next Steps").font(AppTheme.Typography.sectionHeader)
            if openPlanItems.isEmpty {
                Text("No open research plan items.").foregroundStyle(.secondary)
            } else {
                ForEach(openPlanItems.sorted { $0.order < $1.order }.prefix(3)) { item in
                    Text("• \(item.title)")
                }
            }
        }
        .padding()
        .background(AppTheme.cardBackground, in: RoundedRectangle(cornerRadius: 12))
    }
}
