import ServerDrivenKit

enum AppComponentRegistry {
    @MainActor
    static func make() throws -> ComponentRegistry {
        try ComponentRegistry {
            TextComponent.registration
            ImageComponent.registration
            ButtonComponent.registration
            DividerComponent.registration
            DestinationCard.registration
            Badge.registration
            UIKitMapPreview.registration
        }
    }
}
