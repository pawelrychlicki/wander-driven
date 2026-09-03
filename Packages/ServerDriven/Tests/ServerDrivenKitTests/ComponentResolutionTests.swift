import SwiftUI
import Testing

@testable import ServerDrivenKit

struct ComponentResolutionTests {
    @Test("resolves a registered component into a rendered view")
    @MainActor
    func resolvesRegisteredComponent() throws {
        let registry = try ComponentRegistry {
            TestComponent.registration
        }
        let node = ScreenNode(
            id: "known",
            type: TestComponent.componentType,
            properties: .object(["title": .string("Porto")])
        )

        let result = registry.resolve(
            node,
            context: ComponentContext(componentID: node.id)
        )

        guard case .rendered = result else {
            Issue.record("Expected a registered component to render.")
            return
        }
    }

    @Test("contains unknown components without preventing sibling rendering")
    @MainActor
    func resolvesUnknownComponentAsFallback() throws {
        let registry = try ComponentRegistry {
            TestComponent.registration
        }
        let node = ScreenNode(id: "unknown", type: "future.component")

        let result = registry.resolve(
            node,
            context: ComponentContext(componentID: node.id)
        )

        guard case let .unsupported(diagnostic) = result else {
            Issue.record("Expected an unsupported component diagnostic.")
            return
        }
        #expect(diagnostic.code == .unsupportedComponent)
        #expect(diagnostic.componentID == node.id)
        #expect(diagnostic.componentType == node.type)
    }

    @Test("contains invalid properties at the component boundary")
    @MainActor
    func resolvesInvalidPropertiesAsFallback() throws {
        let registry = try ComponentRegistry {
            TestComponent.registration
        }
        let node = ScreenNode(
            id: "invalid",
            type: TestComponent.componentType,
            properties: .object(["title": .number(42)])
        )

        let result = registry.resolve(
            node,
            context: ComponentContext(componentID: node.id)
        )

        guard case let .invalidProperties(diagnostic) = result else {
            Issue.record("Expected an invalid properties diagnostic.")
            return
        }
        #expect(diagnostic.code == .invalidProperties)
        #expect(diagnostic.componentID == node.id)
    }

    @Test("applies a neutral release message while keeping debug details available")
    func appliesDiagnosticPolicy() {
        let diagnostic = RenderDiagnostic(
            code: .invalidProperties,
            componentID: "invalid",
            componentType: "test.component",
            detail: "Expected title to be a string."
        )

        #expect(
            DiagnosticPolicy.debug.message(for: diagnostic) ==
                "Expected title to be a string."
        )
        #expect(
            DiagnosticPolicy.release.message(for: diagnostic) ==
                "This content is temporarily unavailable."
        )
    }

    @SDUIComponent("test.component")
    private struct TestComponent: ComponentDefinition {
        struct Properties: Decodable, Sendable {
            let title: String
        }

        static func makeView(
            properties: Properties,
            context: ComponentContext
        ) -> some View {
            Text(properties.title)
        }
    }
}
