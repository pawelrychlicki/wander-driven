/// Mutable runtime state associated with one component identifier.
public struct ComponentState: Equatable, Sendable {
    public var isFavorite: Bool

    public init(isFavorite: Bool = false) {
        self.isFavorite = isFavorite
    }
}
