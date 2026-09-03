public struct ScreenEffectID: Hashable, Sendable, ExpressibleByStringLiteral, CustomStringConvertible {
    public let rawValue: String

    public init(_ rawValue: String) {
        self.rawValue = rawValue
    }

    public init(stringLiteral value: String) {
        self.init(value)
    }

    public var description: String {
        rawValue
    }
}

public struct ScreenEffectRequest: Equatable, Sendable {
    public enum Kind: Equatable, Sendable {
        case refresh
        case load(String)
        case custom(String)
    }

    public let id: ScreenEffectID
    public let kind: Kind

    public init(id: ScreenEffectID, kind: Kind) {
        self.id = id
        self.kind = kind
    }

    public init(id: String, kind: Kind) {
        self.init(id: ScreenEffectID(id), kind: kind)
    }
}

public enum ScreenEffectResponse: Equatable, Sendable {
    case completed
    case value(JSONValue)
}

public enum ScreenEffectFailure: Equatable, Sendable {
    case cancelled
    case message(String)
}

public enum ScreenEffectResult: Equatable, Sendable {
    case success(ScreenEffectResponse)
    case failure(ScreenEffectFailure)
}

public enum ScreenEffect: Equatable, Sendable {
    case run(id: ScreenEffectID, request: ScreenEffectRequest)
    case forward(ExternalAction)
    case cancel(id: ScreenEffectID)
}

public struct ScreenEffectExecutor: Sendable {
    public typealias Operation = @Sendable (ScreenEffectRequest) async -> ScreenEffectResult

    private let operation: Operation

    public init(
        _ operation: @escaping Operation = { _ in .success(.completed) }
    ) {
        self.operation = operation
    }

    public func run(_ request: ScreenEffectRequest) async -> ScreenEffectResult {
        await operation(request)
    }
}
