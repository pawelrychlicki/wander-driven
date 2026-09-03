@testable import ServerDrivenKit
import SwiftUI
import Testing

struct PrimitiveComponentTests {
    @Test("renders a text component from typed properties")
    @MainActor
    func rendersTextComponent() throws {
        let registry = try ComponentRegistry {
            TextComponent.registration
        }
        let node = ScreenNode(
            id: "headline",
            type: "text",
            properties: .object([
                "text": .string("Discover Lisbon"),
                "style": .string("title"),
            ])
        )

        let result = registry.resolve(
            node,
            context: ComponentContext(componentID: node.id)
        )

        guard case .rendered = result else {
            Issue.record("Expected the text component to render.")
            return
        }
    }

    @Test("renders an image component with an accessibility label")
    @MainActor
    func rendersImageComponent() throws {
        let registry = try ComponentRegistry {
            ImageComponent.registration
        }
        let node = ScreenNode(
            id: "hero-image",
            type: "image",
            properties: .object([
                "systemName": .string("airplane"),
                "accessibilityLabel": .string("Airplane over a coastline"),
            ])
        )

        guard case .rendered = registry.resolve(
            node,
            context: ComponentContext(componentID: node.id)
        ) else {
            Issue.record("Expected the image component to render.")
            return
        }
    }

    @Test("renders a button component and accepts document actions")
    @MainActor
    func rendersButtonComponent() throws {
        let registry = try ComponentRegistry {
            ButtonComponent.registration
        }
        let node = ScreenNode(
            id: "open-lisbon",
            type: "button",
            properties: .object(["title": .string("Explore Lisbon")]),
            actions: [
                DocumentAction(
                    type: "navigate",
                    payload: .object(["destinationID": .string("lisbon")])
                ),
            ]
        )

        guard case .rendered = registry.resolve(
            node,
            context: ComponentContext(
                componentID: node.id,
                actions: node.actions
            )
        ) else {
            Issue.record("Expected the button component to render.")
            return
        }
    }

    @Test("recursively renders a document with supported containers")
    @MainActor
    func rendersNestedContainers() throws {
        let registry = try ComponentRegistry {
            TextComponent.registration
        }
        let document = ScreenDocument(
            schemaVersion: 1,
            root: ScreenNode(
                id: "root",
                type: "vertical",
                properties: .object(["spacing": .number(16)]),
                children: [
                    ScreenNode(
                        id: "row",
                        type: "horizontal",
                        children: [ScreenNode(
                            id: "title",
                            type: "text",
                            properties: .object(["text": .string("Porto")])
                        )]
                    ),
                    ScreenNode(
                        id: "scroll",
                        type: "scroll",
                        children: [ScreenNode(
                            id: "description",
                            type: "text",
                            properties: .object(["text": .string("Atlantic light")])
                        )]
                    ),
                ]
            )
        )

        let view = ScreenRenderer(registry: registry).render(document) { _ in }

        #expect(String(describing: type(of: view)).contains("AnyView"))
    }
}
