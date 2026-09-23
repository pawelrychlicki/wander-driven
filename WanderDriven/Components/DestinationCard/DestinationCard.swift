import ServerDrivenKit
import SwiftUI

@SDUIComponent("destination.card")
struct DestinationCard: ComponentDefinition {
    nonisolated struct Properties: Decodable, Sendable, Equatable {
        let destinationID: String
        let name: String
        let country: String
        let summary: String
        let imageSystemName: String

        init(
            destinationID: String,
            name: String,
            country: String,
            summary: String,
            imageSystemName: String
        ) {
            self.destinationID = destinationID
            self.name = name
            self.country = country
            self.summary = summary
            self.imageSystemName = imageSystemName
        }
    }

    static func favoriteAction(in actions: [DocumentAction]) -> DocumentAction? {
        actions.first(where: { $0.type == "toggleFavorite" })
    }

    @MainActor
    static func makeView(
        properties: Properties,
        context: ComponentContext
    ) -> some View {
        let onFavorite: (@MainActor @Sendable () -> Void)? = if let action = favoriteAction(in: context.actions) {
            { context.send(action) }
        } else {
            nil
        }

        let onSelect: (@MainActor @Sendable () -> Void)? = if let action = context.actions.first(where: { $0.type == "navigate" }) {
            { context.send(action) }
        } else {
            nil
        }

        return DestinationCardView(
            componentID: context.componentID,
            properties: properties,
            isFavorite: context.state.isFavorite,
            onFavorite: onFavorite,
            onSelect: onSelect
        )
    }
}
