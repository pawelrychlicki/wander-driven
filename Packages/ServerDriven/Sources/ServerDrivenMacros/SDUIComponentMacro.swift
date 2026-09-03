import Foundation
import SwiftDiagnostics
import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros

public struct SDUIComponentMacro: MemberMacro {
    public static func expansion(
        of node: AttributeSyntax,
        providingMembersOf declaration: some DeclGroupSyntax,
        conformingTo _: [TypeSyntax],
        in context: some MacroExpansionContext
    ) -> [DeclSyntax] {
        guard declaration.is(StructDeclSyntax.self) else {
            context.diagnose(
                Diagnostic(
                    node: node,
                    message: SDUIComponentDiagnostic(
                        "@SDUIComponent can only be attached to a struct."
                    )
                )
            )
            return []
        }

        guard let identifierLiteral = identifierLiteral(from: node),
              let identifier = identifierLiteral.segments.first?.as(StringSegmentSyntax.self)?.content.text,
              identifierLiteral.segments.count == 1
        else {
            context.diagnose(
                Diagnostic(
                    node: node,
                    message: SDUIComponentDiagnostic(
                        "@SDUIComponent requires a simple string literal identifier."
                    )
                )
            )
            return []
        }

        guard !identifier.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            context.diagnose(
                Diagnostic(
                    node: node,
                    message: SDUIComponentDiagnostic(
                        "Component identifiers must not be empty."
                    )
                )
            )
            return []
        }

        let visibility = declaration.modifiers.contains {
            $0.name.text == "public"
        } ? "public " : ""

        return [
            "\(raw: visibility)static let componentType: String = \(identifierLiteral)",
            """
            @MainActor
            \(raw: visibility)static var registration: AnyComponentRegistration {
                AnyComponentRegistration(Self.self)
            }
            """,
        ]
    }

    private static func identifierLiteral(
        from node: AttributeSyntax
    ) -> StringLiteralExprSyntax? {
        guard let arguments = node.arguments?.as(LabeledExprListSyntax.self),
              let firstArgument = arguments.first
        else {
            return nil
        }

        return firstArgument.expression.as(StringLiteralExprSyntax.self)
    }
}

private struct SDUIComponentDiagnostic: DiagnosticMessage {
    let message: String

    init(_ message: String) {
        self.message = message
    }

    var diagnosticID: MessageID {
        MessageID(
            domain: "ServerDrivenMacros",
            id: "SDUIComponentMacro"
        )
    }

    var severity: DiagnosticSeverity {
        .error
    }
}
