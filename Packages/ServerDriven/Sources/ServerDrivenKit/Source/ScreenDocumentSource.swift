import Foundation

public enum ScreenDocumentSourceError: Error, Equatable, Sendable, CustomStringConvertible {
    case resourceNotFound(String)
    case unreadableResource(name: String, detail: String)
    case invalidDocument(name: String, detail: String)

    public var description: String {
        switch self {
        case let .resourceNotFound(name):
            "The screen document resource '\(name)' was not found."
        case let .unreadableResource(name, detail):
            "The screen document resource '\(name)' could not be read: \(detail)"
        case let .invalidDocument(name, detail):
            "The screen document resource '\(name)' is invalid: \(detail)"
        }
    }
}

@MainActor
public protocol ScreenDocumentSource {
    func loadDocument(named name: String) throws -> ScreenDocument
}
