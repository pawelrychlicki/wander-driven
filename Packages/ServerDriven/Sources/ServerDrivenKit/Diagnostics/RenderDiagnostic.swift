import Foundation

public enum RenderDiagnosticCode: String, Equatable, Sendable {
    case unsupportedComponent
    case invalidProperties
}

public struct RenderDiagnostic: Equatable, Sendable {
    public let code: RenderDiagnosticCode
    public let componentID: ComponentID
    public let componentType: String
    public let detail: String

    public init(
        code: RenderDiagnosticCode,
        componentID: ComponentID,
        componentType: String,
        detail: String
    ) {
        self.code = code
        self.componentID = componentID
        self.componentType = componentType
        self.detail = detail
    }
}

public enum DiagnosticPolicy: Sendable {
    case debug
    case release

    public func message(for diagnostic: RenderDiagnostic) -> String {
        switch self {
        case .debug:
            diagnostic.detail
        case .release:
            "This content is temporarily unavailable."
        }
    }
}
