import Foundation

public struct DocumentValidator: Sendable {
    public let supportedSchemaVersions: Set<Int>

    public init(supportedSchemaVersions: Set<Int> = [1]) {
        self.supportedSchemaVersions = supportedSchemaVersions
    }

    public func validate(_ document: ScreenDocument) -> [ValidationIssue] {
        var issues: [ValidationIssue] = []

        if !supportedSchemaVersions.contains(document.schemaVersion) {
            issues.append(
                ValidationIssue(
                    code: .unsupportedSchemaVersion,
                    message: "Schema version \(document.schemaVersion) is not supported."
                )
            )
        }

        var seenIDs = Set<ComponentID>()
        validate(
            node: document.root,
            seenIDs: &seenIDs,
            issues: &issues
        )

        return issues
    }

    private func validate(
        node: ScreenNode,
        seenIDs: inout Set<ComponentID>,
        issues: inout [ValidationIssue]
    ) {
        if node.id.rawValue.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            issues.append(
                ValidationIssue(
                    code: .emptyComponentID,
                    componentID: node.id,
                    message: "Component identifiers must not be empty."
                )
            )
        } else if !seenIDs.insert(node.id).inserted {
            issues.append(
                ValidationIssue(
                    code: .duplicateComponentID,
                    componentID: node.id,
                    message: "Component identifier '\(node.id)' is used more than once."
                )
            )
        }

        if node.type.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            issues.append(
                ValidationIssue(
                    code: .emptyComponentType,
                    componentID: node.id,
                    message: "Component types must not be empty."
                )
            )
        }

        if !isContainer(node.type), !node.children.isEmpty {
            issues.append(
                ValidationIssue(
                    code: .invalidContainerChildren,
                    componentID: node.id,
                    message: "Component '\(node.type)' cannot contain child nodes."
                )
            )
        }

        for action in node.actions {
            validate(action: action, on: node, issues: &issues)
        }

        for child in node.children {
            validate(node: child, seenIDs: &seenIDs, issues: &issues)
        }
    }

    private func validate(
        action: DocumentAction,
        on node: ScreenNode,
        issues: inout [ValidationIssue]
    ) {
        switch action.type {
        case "navigate", "toggleFavorite":
            requireString(
                field: "destinationID",
                in: action.payload,
                node: node,
                issues: &issues
            )
        case "showAlert":
            requireString(
                field: "title",
                in: action.payload,
                node: node,
                issues: &issues
            )
            requireString(
                field: "message",
                in: action.payload,
                node: node,
                issues: &issues
            )
        default:
            break
        }
    }

    private func requireString(
        field: String,
        in payload: JSONValue?,
        node: ScreenNode,
        issues: inout [ValidationIssue]
    ) {
        guard case let .object(values) = payload,
              case let .string(value) = values[field],
              !value.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            issues.append(
                ValidationIssue(
                    code: .missingActionField,
                    componentID: node.id,
                    field: field,
                    message: "Action on component '\(node.id)' requires a non-empty '\(field)' field."
                )
            )
            return
        }
    }

    private func isContainer(_ type: String) -> Bool {
        switch type {
        case "vertical", "horizontal", "scroll":
            true
        default:
            false
        }
    }
}
