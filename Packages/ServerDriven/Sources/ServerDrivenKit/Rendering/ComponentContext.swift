import Foundation

/// The narrow context a component receives while it is rendered.
public struct ComponentContext: Sendable {
    public let componentID: ComponentID
    public let actions: [DocumentAction]
    public let state: ComponentState
    public let send: @MainActor @Sendable (DocumentAction) -> Void

    public init(
        componentID: ComponentID,
        actions: [DocumentAction] = [],
        state: ComponentState = ComponentState(),
        send: @escaping @MainActor @Sendable (DocumentAction) -> Void = { _ in }
    ) {
        self.componentID = componentID
        self.actions = actions
        self.state = state
        self.send = send
    }
}
