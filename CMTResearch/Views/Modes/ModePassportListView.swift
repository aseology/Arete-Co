import SwiftUI
import SwiftData

struct ModePassportListView: View {
    @Query(sort: \ModePassport.name) private var modes: [ModePassport]

    var body: some View {
        List(modes) { mode in
            NavigationLink {
                ModePassportDetailView(mode: mode)
            } label: {
                VStack(alignment: .leading, spacing: 4) {
                    Text(mode.name).font(.headline)
                    if !mode.workingDefinition.isEmpty {
                        Text(mode.workingDefinition)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .lineLimit(2)
                    }
                    HStack(spacing: 4) {
                        Circle()
                            .fill(AppTheme.statusColor(mode.validationStatus))
                            .frame(width: 8, height: 8)
                        Text(mode.validationStatus.rawValue)
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                    }
                }
                .padding(.vertical, 2)
            }
        }
        .navigationTitle("Mode Passports")
    }
}
