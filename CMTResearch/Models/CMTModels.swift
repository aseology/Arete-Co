import Foundation
import SwiftData

enum ValidationStatus: String, Codable, CaseIterable, Identifiable {
    case proposed = "Proposed"
    case underReview = "Under Review"
    case validated = "Validated"
    case rejected = "Rejected"

    var id: String { rawValue }
}

enum EvidenceType: String, Codable, CaseIterable, Identifiable {
    case conceptual = "Conceptual"
    case observational = "Observational"
    case crossDomain = "Cross-Domain"
    case literature = "Literature"
    case behavioral = "Behavioral"
    case transformational = "Transformational"
    case ecological = "Ecological"
    case sequence = "Sequence"
    case predictive = "Predictive"

    var id: String { rawValue }
}

enum EvidenceStance: String, Codable, CaseIterable, Identifiable {
    case supports = "Supports"
    case contradicts = "Contradicts"
    case neutral = "Neutral / Observational"

    var id: String { rawValue }
}

/// The atomic unit of CMT: a Mode Passport documents one proposed cognitive mode
/// and the evidence accumulated for or against it.
@Model
final class ModePassport {
    var name: String
    var workingDefinition: String
    var canonicalQuestion: String
    var primaryCognitiveOperation: String
    var proposedTransformation: String
    var behavioralExamples: [String]
    var occupationalExamples: [String]
    var ecologicalSupports: [String]
    var entryCost: Int
    var maintenanceCost: Int
    var exitCost: Int
    var openResearchQuestions: [String]
    var revisionNotes: String
    var validationStatus: ValidationStatus
    var dateCreated: Date
    var dateUpdated: Date

    @Relationship(deleteRule: .nullify, inverse: \EvidenceEntry.relatedMode)
    var evidenceEntries: [EvidenceEntry] = []

    @Relationship(deleteRule: .nullify, inverse: \DecompositionStep.mode)
    var decompositionSteps: [DecompositionStep] = []

    @Relationship(deleteRule: .nullify, inverse: \OpenQuestion.relatedMode)
    var linkedOpenQuestions: [OpenQuestion] = []

    init(
        name: String,
        workingDefinition: String = "",
        canonicalQuestion: String = "",
        primaryCognitiveOperation: String = "",
        proposedTransformation: String = "",
        behavioralExamples: [String] = [],
        occupationalExamples: [String] = [],
        ecologicalSupports: [String] = [],
        entryCost: Int = 3,
        maintenanceCost: Int = 3,
        exitCost: Int = 3,
        openResearchQuestions: [String] = [],
        revisionNotes: String = "",
        validationStatus: ValidationStatus = .proposed,
        dateCreated: Date = .now,
        dateUpdated: Date = .now
    ) {
        self.name = name
        self.workingDefinition = workingDefinition
        self.canonicalQuestion = canonicalQuestion
        self.primaryCognitiveOperation = primaryCognitiveOperation
        self.proposedTransformation = proposedTransformation
        self.behavioralExamples = behavioralExamples
        self.occupationalExamples = occupationalExamples
        self.ecologicalSupports = ecologicalSupports
        self.entryCost = entryCost
        self.maintenanceCost = maintenanceCost
        self.exitCost = exitCost
        self.openResearchQuestions = openResearchQuestions
        self.revisionNotes = revisionNotes
        self.validationStatus = validationStatus
        self.dateCreated = dateCreated
        self.dateUpdated = dateUpdated
    }
}

/// A task container decomposed into an ordered sequence of cognitive steps.
@Model
final class DecompositionCase {
    var title: String
    var intentDescription: String
    var domain: String
    var notes: String
    var dateCreated: Date

    @Relationship(deleteRule: .cascade, inverse: \DecompositionStep.decompositionCase)
    var steps: [DecompositionStep] = []

    init(
        title: String,
        intentDescription: String = "",
        domain: String = "",
        notes: String = "",
        dateCreated: Date = .now
    ) {
        self.title = title
        self.intentDescription = intentDescription
        self.domain = domain
        self.notes = notes
        self.dateCreated = dateCreated
    }

    var orderedSteps: [DecompositionStep] {
        steps.sorted { $0.order < $1.order }
    }
}

/// A single step within a Decomposition Case, mapped to the mode it recruits.
@Model
final class DecompositionStep {
    var order: Int
    var stepDescription: String
    var decompositionCase: DecompositionCase?
    var mode: ModePassport?

    init(
        order: Int,
        stepDescription: String,
        decompositionCase: DecompositionCase? = nil,
        mode: ModePassport? = nil
    ) {
        self.order = order
        self.stepDescription = stepDescription
        self.decompositionCase = decompositionCase
        self.mode = mode
    }
}

/// A single logged observation supporting, contradicting, or informing a Mode Passport.
@Model
final class EvidenceEntry {
    var dateLogged: Date
    var evidenceType: EvidenceType
    var stance: EvidenceStance
    var entryDescription: String
    var source: String
    var relatedMode: ModePassport?

    init(
        dateLogged: Date = .now,
        evidenceType: EvidenceType = .observational,
        stance: EvidenceStance = .neutral,
        entryDescription: String = "",
        source: String = "",
        relatedMode: ModePassport? = nil
    ) {
        self.dateLogged = dateLogged
        self.evidenceType = evidenceType
        self.stance = stance
        self.entryDescription = entryDescription
        self.source = source
        self.relatedMode = relatedMode
    }
}

@Model
final class GlossaryTerm {
    var term: String
    var definition: String

    init(term: String, definition: String) {
        self.term = term
        self.definition = definition
    }
}

@Model
final class OpenQuestion {
    var questionText: String
    var dateCreated: Date
    var isResolved: Bool
    var relatedMode: ModePassport?

    init(
        questionText: String,
        dateCreated: Date = .now,
        isResolved: Bool = false,
        relatedMode: ModePassport? = nil
    ) {
        self.questionText = questionText
        self.dateCreated = dateCreated
        self.isResolved = isResolved
        self.relatedMode = relatedMode
    }
}

@Model
final class ResearchPlanItem {
    var title: String
    var detail: String
    var isComplete: Bool
    var order: Int

    init(
        title: String,
        detail: String = "",
        isComplete: Bool = false,
        order: Int = 0
    ) {
        self.title = title
        self.detail = detail
        self.isComplete = isComplete
        self.order = order
    }
}
