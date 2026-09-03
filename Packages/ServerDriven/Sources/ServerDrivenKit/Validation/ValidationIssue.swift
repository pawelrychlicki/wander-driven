import Foundation

public enum ValidationIssueCode: String, Equatable, Sendable {
    case unsupportedSchemaVersion
    case duplicateComponentID
    case invalidContainerChildren
    case missingActionField
    case emptyComponentID
    case emptyComponentType
}

public struct ValidationIssue: Equatable, Sendable, CustomStringConvertible {
    public let code: ValidationIssueCode
    public let componentID: ComponentID?
    public let field: String?
    public let message: String

    public init(
        code: ValidationIssueCode,
        componentID: ComponentID? = nil,
        field: String? = nil,
        message: String
    ) {
        self.code = code
        self.componentID = componentID
        self.field = field
        self.message = message
    }

    public var description: String {
        message
    }
}
