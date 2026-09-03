import Foundation

public struct AlertState: Equatable, Sendable, Identifiable {
    public let id: String
    public let title: String
    public let message: String

    public init(id: String? = nil, title: String, message: String) {
        self.title = title
        self.message = message
        self.id = id ?? "\(title)|\(message)"
    }
}

/// Normalized runtime state. The immutable screen document intentionally does not live here.
public struct ScreenState: Equatable, Sendable {
    public var componentStates: [ComponentID: ComponentState]
    public var presentedAlert: AlertState?
    public var activeEffectIDs: Set<ScreenEffectID>
    public var lastEffectResult: ScreenEffectResult?

    public init(
        componentStates: [ComponentID: ComponentState] = [:],
        presentedAlert: AlertState? = nil,
        activeEffectIDs: Set<ScreenEffectID> = [],
        lastEffectResult: ScreenEffectResult? = nil
    ) {
        self.componentStates = componentStates
        self.presentedAlert = presentedAlert
        self.activeEffectIDs = activeEffectIDs
        self.lastEffectResult = lastEffectResult
    }

    public init(document: ScreenDocument) {
        var componentStates: [ComponentID: ComponentState] = [:]
        Self.collectState(for: document.root, into: &componentStates)
        self.init(componentStates: componentStates)
    }

    public subscript(componentID: ComponentID) -> ComponentState {
        get {
            componentStates[componentID, default: ComponentState()]
        }
        set {
            componentStates[componentID] = newValue
        }
    }

    private static func collectState(
        for node: ScreenNode,
        into componentStates: inout [ComponentID: ComponentState]
    ) {
        componentStates[node.id] = ComponentState()
        for child in node.children {
            collectState(for: child, into: &componentStates)
        }
    }
}
