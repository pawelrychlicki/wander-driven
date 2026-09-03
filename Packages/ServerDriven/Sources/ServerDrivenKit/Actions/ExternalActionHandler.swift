public enum ExternalAction: Equatable, Sendable {
    case navigate(destinationID: ComponentID)
    case custom(type: String, payload: JSONValue?)
}

/// App-owned boundary for actions that ServerDrivenKit cannot execute itself.
public struct ExternalActionHandler: Sendable {
    public let send: @MainActor @Sendable (ExternalAction) -> Void

    public init(
        _ send: @escaping @MainActor @Sendable (ExternalAction) -> Void = { _ in }
    ) {
        self.send = send
    }

    @MainActor
    public func handle(_ action: ExternalAction) {
        send(action)
    }
}
