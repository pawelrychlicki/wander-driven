import Foundation

/// An immutable, validated-at-the-boundary definition of a server-driven screen.
public struct ScreenDocument: Codable, Equatable, Sendable {
    public let schemaVersion: Int
    public let root: ScreenNode

    public init(schemaVersion: Int, root: ScreenNode) {
        self.schemaVersion = schemaVersion
        self.root = root
    }
}

/// A recursive node in a screen document.
public struct ScreenNode: Codable, Equatable, Sendable, Identifiable {
    public let id: ComponentID
    public let type: String
    public let properties: JSONValue
    public let children: [ScreenNode]
    public let actions: [DocumentAction]

    public init(
        id: ComponentID,
        type: String,
        properties: JSONValue = .object([:]),
        children: [ScreenNode] = [],
        actions: [DocumentAction] = []
    ) {
        self.id = id
        self.type = type
        self.properties = properties
        self.children = children
        self.actions = actions
    }

    private enum CodingKeys: String, CodingKey {
        case id
        case type
        case properties
        case children
        case actions
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(ComponentID.self, forKey: .id)
        type = try container.decode(String.self, forKey: .type)
        properties = try container.decodeIfPresent(JSONValue.self, forKey: .properties) ?? .object([:])
        children = try container.decodeIfPresent([ScreenNode].self, forKey: .children) ?? []
        actions = try container.decodeIfPresent([DocumentAction].self, forKey: .actions) ?? []
    }
}

/// An action declared by a document. It is interpreted by the runtime or host app.
public struct DocumentAction: Codable, Equatable, Sendable {
    public let type: String
    public let payload: JSONValue?

    public init(type: String, payload: JSONValue? = nil) {
        self.type = type
        self.payload = payload
    }
}
