import ServerDrivenKit
import Testing
@testable import WanderDriven

struct DestinationCardTests {
    @Test("decodes destination card properties and registers the travel component")
    @MainActor
    func decodesDestinationCardProperties() throws {
        let registry = try ComponentRegistry {
            DestinationCard.registration
        }
        let node = ScreenNode(
            id: "lisbon-card",
            type: "destination.card",
            properties: .object([
                "destinationID": .string("lisbon"),
                "name": .string("Lisbon"),
                "country": .string("Portugal"),
                "summary": .string("Sunlit streets and Atlantic air."),
                "imageSystemName": .string("sun.horizon"),
            ])
        )

        guard case .rendered = registry.resolve(
            node,
            context: ComponentContext(componentID: node.id)
        ) else {
            Issue.record("Expected the destination card to render.")
            return
        }
    }

    @Test("preserves a declared favorite action and provides a safe fallback")
    func buildsFavoriteAction() {
        let properties = DestinationCard.Properties(
            destinationID: "lisbon",
            name: "Lisbon",
            country: "Portugal",
            summary: "Sunlit streets and Atlantic air.",
            imageSystemName: "sun.horizon"
        )
        let declaredAction = DocumentAction(
            type: "toggleFavorite",
            payload: .object(["destinationID": .string("lisbon")])
        )

        #expect(
            DestinationCard.favoriteAction(
                for: properties,
                actions: [declaredAction]
            ) == declaredAction
        )
        #expect(
            DestinationCard.favoriteAction(for: properties, actions: []) ==
                declaredAction
        )
    }
}
