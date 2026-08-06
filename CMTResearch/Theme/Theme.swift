import SwiftUI

/// Shared design tokens for the CMT Research tool. This is an internal research
/// instrument, not the consumer-facing app, so it stays native and quiet rather
/// than themed.
enum AppTheme {
    static let background = Color(.systemGroupedBackground)
    static let cardBackground = Color(.secondarySystemGroupedBackground)

    static func statusColor(_ status: ValidationStatus) -> Color {
        switch status {
        case .proposed: return .gray
        case .underReview: return .orange
        case .validated: return .green
        case .rejected: return .red
        }
    }

    static func stanceColor(_ stance: EvidenceStance) -> Color {
        switch stance {
        case .supports: return .green
        case .contradicts: return .red
        case .neutral: return .gray
        }
    }

    enum Spacing {
        static let small: CGFloat = 6
        static let medium: CGFloat = 12
        static let large: CGFloat = 20
    }

    enum Typography {
        static let sectionHeader = Font.headline
        static let body = Font.body
        static let caption = Font.caption
    }
}
