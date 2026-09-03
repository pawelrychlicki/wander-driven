import Foundation

/// The narrow context a component receives while it is rendered.
public struct ComponentContext: Sendable {
    public let componentID: ComponentID
    public let send: @MainActor @Sendable (DocumentAction) -> Void

    public init(
        componentID: ComponentID,
        send: @escaping @MainActor @Sendable (DocumentAction) -> Void = { _ in }
    ) {
        self.componentID = componentID
        self.send = send
    }
}
