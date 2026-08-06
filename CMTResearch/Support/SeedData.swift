import Foundation
import SwiftData

/// Populates the store with the nine provisional modes, the current glossary,
/// the stabilization-phase research plan, and starting open questions — all
/// drawn directly from the CMT Research Summary v0.1. Evidence and
/// Decomposition Cases are left empty; those are meant to be logged from real
/// observation, not seeded.
struct SeedData {
    static func populateIfNeeded(context: ModelContext) {
        let existing = try? context.fetch(FetchDescriptor<ModePassport>())
        guard existing?.isEmpty ?? true else { return }

        let modeSeeds: [(name: String, definition: String, question: String, operation: String, transformation: String, status: ValidationStatus)] = [
            ("Observation", "Attends to incoming information in order to identify what is present.", "What is actually here?", "Attending to raw information without yet interpreting it.", "Unattended stimulus → attended, identified information.", .underReview),
            ("Exploration", "Expands the search space by generating possibilities and seeking additional information.", "What else might be true or possible?", "Generating and searching for possibilities.", "A fixed set of known information → an expanded set of possibilities.", .proposed),
            ("Synthesis", "Integrates multiple representations into a coherent mental model.", "How does this all fit together?", "Integrating disparate representations into one model.", "Fragmented representations → a coherent mental model.", .proposed),
            ("Strategy", "Evaluates a mental model against goals and constraints in order to generate candidate directions.", "Given where I want to go, what are my options?", "Evaluating a model against goals and constraints.", "A coherent mental model → a set of candidate directions.", .proposed),
            ("Decision", "Selects a direction from competing alternatives and commits to a course of action.", "Which option am I committing to?", "Selecting and committing to one alternative.", "Multiple candidate directions → one committed direction.", .proposed),
            ("Creation", "Externalizes an internal representation into an artifact such as writing, software, design, or speech.", "How do I get this out of my head and into the world?", "Externalizing an internal representation into an artifact.", "An internal representation → an external artifact.", .proposed),
            ("Refinement", "Improves an artifact through revision, editing, debugging, or iteration.", "What needs to change to make this right?", "Improving an existing artifact through iteration.", "A draft artifact → an improved artifact.", .proposed),
            ("Execution", "Transforms a completed artifact into action within the real world.", "How does this actually get done?", "Transforming a completed artifact into real-world action.", "A completed artifact → real-world action or outcome.", .proposed),
            ("Reflection", "Evaluates the outcome of an action and transforms experience into learning that can inform future work.", "What did this teach me?", "Evaluating outcomes and converting experience into learning.", "A raw outcome or experience → applied learning.", .proposed),
        ]

        for seed in modeSeeds {
            context.insert(ModePassport(
                name: seed.name,
                workingDefinition: seed.definition,
                canonicalQuestion: seed.question,
                primaryCognitiveOperation: seed.operation,
                proposedTransformation: seed.transformation,
                validationStatus: seed.status
            ))
        }

        let glossarySeeds: [(term: String, definition: String)] = [
            ("Cognitive Mode Theory (CMT)", "A working model proposing that the fundamental unit of cognitive work is the cognitive process, not the task."),
            ("Cognitive Load Sequencing (CLS)", "The operational application of CMT: ordering decomposed cognitive steps to minimize unnecessary transitions while preserving momentum."),
            ("Mode Mapping", "The process of assigning each decomposed step of a task to its corresponding cognitive mode."),
            ("Task Container", "A project-level label (e.g. \"launch an event\") that describes an outcome rather than a cognitive process; must be decomposed before it can be optimized."),
            ("Mode Passport", "The atomic documentation unit of the theory: definition, canonical question, operation, transformation, examples, ecological signature, cost profile, evidence, validation status, and open questions for one mode."),
            ("Ecological Signature", "The environmental conditions that support or inhibit a given cognitive mode."),
            ("Cognitive Cost Profile", "The documented effort required to enter, maintain, exit, and transition into or out of a mode."),
            ("Definition Independence", "A validation criterion requiring that a mode be definable without relying on another mode for its explanation."),
            ("Behavioral Diversity", "A validation criterion requiring that a mode be expressible through many different behaviors rather than one specific activity."),
            ("Universality", "A validation criterion requiring that a mode's operation appear across multiple occupations and domains."),
            ("Sequence Flexibility", "A validation criterion requiring that a mode not depend on occupying a single fixed position within a process."),
        ]
        for seed in glossarySeeds {
            context.insert(GlossaryTerm(term: seed.term, definition: seed.definition))
        }

        let planSeeds: [(title: String, detail: String, order: Int)] = [
            ("Build a complete Mode Passport for Observation", "Use it as the template for every subsequent mode.", 0),
            ("Start an evidence log", "Capture every observation before it enters the theory.", 1),
            ("Review relevant literature with specific research questions", "Look for convergent or contradictory support, not identical terminology.", 2),
            ("Decompose real projects into constituent cognitive processes", "Test whether the taxonomy consistently explains how cognition is organized across domains.", 3),
            ("Refine the validation methodology through repeated application", "Apply Definition Independence, Behavioral Diversity, Universality, and Sequence Flexibility to each candidate mode.", 4),
        ]
        for seed in planSeeds {
            context.insert(ResearchPlanItem(title: seed.title, detail: seed.detail, order: seed.order))
        }

        let questionSeeds = [
            "What are the precise input and output states for each mode's transformation?",
            "Do all nine proposed modes satisfy Definition Independence, or do any rely on another mode to be understood?",
            "Which modes, if any, are missing from the current taxonomy?",
            "How should Cognitive Cost Profiles be measured rather than self-reported?",
        ]
        for text in questionSeeds {
            context.insert(OpenQuestion(questionText: text))
        }

        try? context.save()
    }
}
