@testable import ServerDrivenMacros
import SwiftSyntaxMacros
import SwiftSyntaxMacrosTestSupport
import Testing

struct SDUIComponentMacroTests {
    @Test("generates the component type and registry adapter")
    func expandsComponentDeclaration() {
        assertMacroExpansion(
            """
            @SDUIComponent("destinationCard")
            struct DestinationCard {}
            """,
            expandedSource: """
            struct DestinationCard {
                static let componentType: String = "destinationCard"
                @MainActor
                static var registration: AnyComponentRegistration {
                    AnyComponentRegistration(Self.self)
                }
            }
            """,
            macros: ["SDUIComponent": SDUIComponentMacro.self]
        )
    }

    @Test("diagnoses an empty component identifier")
    func diagnosesEmptyIdentifier() {
        assertMacroExpansion(
            """
            @SDUIComponent("")
            struct DestinationCard {}
            """,
            expandedSource: """
            struct DestinationCard {}
            """,
            diagnostics: [
                DiagnosticSpec(
                    message: "Component identifiers must not be empty.",
                    line: 1,
                    column: 1
                ),
            ],
            macros: ["SDUIComponent": SDUIComponentMacro.self]
        )
    }
}
