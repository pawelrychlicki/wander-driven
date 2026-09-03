import Testing

@testable import ServerDrivenKit

struct DocumentValidationTests {
    @Test("accepts a valid version one document")
    func acceptsValidDocument() {
        let document = ScreenDocument(
            schemaVersion: 1,
            root: ScreenNode(
                id: "root",
                type: "vertical",
                children: [
                    ScreenNode(id: "title", type: "text"),
                    ScreenNode(id: "details", type: "destinationCard", actions: [
                        DocumentAction(
                            type: "navigate",
                            payload: .object([
                                "destinationID": .string("lisbon")
                            ])
                        )
                    ])
                ]
            )
        )

        #expect(DocumentValidator().validate(document).isEmpty)
    }

    @Test("reports an unsupported schema version")
    func reportsUnsupportedSchemaVersion() {
        let document = ScreenDocument(
            schemaVersion: 2,
            root: ScreenNode(id: "root", type: "vertical")
        )

        let issues = DocumentValidator().validate(document)

        #expect(issues.contains { $0.code == .unsupportedSchemaVersion })
    }

    @Test("reports duplicate component identifiers anywhere in the tree")
    func reportsDuplicateIDs() {
        let document = ScreenDocument(
            schemaVersion: 1,
            root: ScreenNode(
                id: "root",
                type: "vertical",
                children: [
                    ScreenNode(id: "duplicate", type: "text"),
                    ScreenNode(id: "nested", type: "vertical", children: [
                        ScreenNode(id: "duplicate", type: "badge")
                    ])
                ]
            )
        )

        let issues = DocumentValidator().validate(document)

        #expect(issues.contains {
            $0.code == .duplicateComponentID && $0.componentID == "duplicate"
        })
    }

    @Test("rejects children on a leaf component")
    func rejectsChildrenOnLeaf() {
        let document = ScreenDocument(
            schemaVersion: 1,
            root: ScreenNode(
                id: "root",
                type: "text",
                children: [ScreenNode(id: "child", type: "badge")]
            )
        )

        let issues = DocumentValidator().validate(document)

        #expect(issues.contains {
            $0.code == .invalidContainerChildren && $0.componentID == "root"
        })
    }

    @Test("requires a destination identifier for navigate actions")
    func reportsMissingActionField() {
        let document = ScreenDocument(
            schemaVersion: 1,
            root: ScreenNode(
                id: "root",
                type: "button",
                actions: [DocumentAction(type: "navigate")]
            )
        )

        let issues = DocumentValidator().validate(document)

        #expect(issues.contains {
            $0.code == .missingActionField && $0.field == "destinationID"
        })
    }

    @Test("reports empty component identifiers and types")
    func reportsEmptyIdentityFields() {
        let document = ScreenDocument(
            schemaVersion: 1,
            root: ScreenNode(id: "", type: "")
        )

        let issues = DocumentValidator().validate(document)

        #expect(issues.contains { $0.code == .emptyComponentID })
        #expect(issues.contains { $0.code == .emptyComponentType })
    }
}
