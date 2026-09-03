import Foundation
import Testing

@testable import ServerDrivenKit

struct DocumentDecodingTests {
    @Test("decodes a versioned recursive screen document")
    func decodesValidDocument() throws {
        let document = try JSONDecoder().decode(
            ScreenDocument.self,
            from: Data(Self.validDocument.utf8)
        )

        #expect(document.schemaVersion == 1)
        #expect(document.root.id == "discover-root")
        #expect(document.root.type == "vertical")
        #expect(document.root.children.count == 2)
        #expect(document.root.children[0].type == "text")
        #expect(
            document.root.children[0].properties == .object([
                "text": .string("Explore your next escape")
            ])
        )
        #expect(document.root.children[1].actions == [
            DocumentAction(type: "navigate", payload: .object([
                "destinationID": .string("lisbon")
            ]))
        ])
    }

    @Test("round trips JSON values without erasing their shape")
    func roundTripsJSONValue() throws {
        let value: JSONValue = .object([
            "enabled": .bool(true),
            "count": .number(3),
            "tags": .array([.string("coast"), .null])
        ])

        let encoded = try JSONEncoder().encode(value)
        let decoded = try JSONDecoder().decode(JSONValue.self, from: encoded)

        #expect(decoded == value)
    }

    @Test("rejects a document without a schema version and root")
    func rejectsInvalidRoot() {
        let invalidJSON = "{\"name\":\"missing-root\"}"

        #expect(throws: DecodingError.self) {
            try JSONDecoder().decode(
                ScreenDocument.self,
                from: Data(invalidJSON.utf8)
            )
        }
    }

    @Test("rejects the invalid root fixture")
    func rejectsInvalidRootFixture() throws {
        let fixtureURL = try #require(
            Bundle.module.url(
                forResource: "invalid-root",
                withExtension: "json"
            )
        )
        let fixtureData = try Data(contentsOf: fixtureURL)

        #expect(throws: DecodingError.self) {
            try JSONDecoder().decode(ScreenDocument.self, from: fixtureData)
        }
    }

    private static let validDocument = """
    {
      "schemaVersion": 1,
      "root": {
        "id": "discover-root",
        "type": "vertical",
        "properties": { "spacing": 16 },
        "children": [
          {
            "id": "discover-title",
            "type": "text",
            "properties": { "text": "Explore your next escape" }
          },
          {
            "id": "lisbon-card",
            "type": "destinationCard",
            "properties": {
              "destinationID": "lisbon",
              "title": "Lisbon",
              "imageName": "lisbon"
            },
            "actions": [
              {
                "type": "navigate",
                "payload": { "destinationID": "lisbon" }
              }
            ]
          }
        ]
      }
    }
    """
}
