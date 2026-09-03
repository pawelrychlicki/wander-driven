import SwiftUI
import Testing

@testable import ServerDrivenKit

struct ComponentRegistryTests {
    @Test("registers and resolves a strongly typed component")
    @MainActor
    func registersComponent() throws {
        let registry = try ComponentRegistry {
            TestTitle.registration
        }
        let node = ScreenNode(
            id: "title",
            type: TestTitle.componentType,
            properties: .object(["text": .string("Lisbon")])
        )
        let context = ComponentContext(componentID: node.id) { _ in }

        let view = try registry.makeView(for: node, context: context)

        #expect(registry.registration(for: TestTitle.componentType) != nil)
        #expect(String(describing: type(of: view)).contains("AnyView"))
    }

    @Test("keeps registrations independent between registry instances")
    @MainActor
    func keepsRegistriesIndependent() throws {
        let titles = try ComponentRegistry {
            TestTitle.registration
        }
        let badges = try ComponentRegistry {
            TestBadge.registration
        }

        #expect(titles.registration(for: TestTitle.componentType) != nil)
        #expect(titles.registration(for: TestBadge.componentType) == nil)
        #expect(badges.registration(for: TestBadge.componentType) != nil)
        #expect(badges.registration(for: TestTitle.componentType) == nil)
    }

    @Test("rejects duplicate component types deterministically")
    @MainActor
    func rejectsDuplicateRegistration() {
        #expect(throws: ComponentRegistryError.self) {
            try ComponentRegistry {
                TestTitle.registration
                TestTitle.registration
            }
        }
    }

    @Test("reports missing component lookup")
    @MainActor
    func reportsMissingLookup() throws {
        let registry = try ComponentRegistry {
            TestTitle.registration
        }

        #expect(registry.registration(for: "missing") == nil)
    }

    @SDUIComponent("test.title")
    private struct TestTitle: ComponentDefinition {
        struct Properties: Decodable, Sendable {
            let text: String
        }

        static func makeView(
            properties: Properties,
            context: ComponentContext
        ) -> some View {
            Text(properties.text)
        }
    }

    @SDUIComponent("test.badge")
    private struct TestBadge: ComponentDefinition {
        struct Properties: Decodable, Sendable {
            let label: String
        }

        static func makeView(
            properties: Properties,
            context: ComponentContext
        ) -> some View {
            Text(properties.label)
        }
    }
}
