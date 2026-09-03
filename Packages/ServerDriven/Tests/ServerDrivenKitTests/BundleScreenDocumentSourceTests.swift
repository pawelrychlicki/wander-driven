import Foundation
@testable import ServerDrivenKit
import Testing

struct BundleScreenDocumentSourceTests {
    @Test("loads a valid document from the injected bundle")
    @MainActor
    func loadsValidDocument() throws {
        let source = BundleScreenDocumentSource(bundle: Bundle.module)

        let document = try source.loadDocument(named: "source-valid")

        #expect(document.schemaVersion == 1)
        #expect(document.root.id == "source-root")
        #expect(document.root.children.map(\.id) == ["source-title"])
    }

    @Test("reports a missing document resource")
    @MainActor
    func reportsMissingResource() {
        let source = BundleScreenDocumentSource(bundle: Bundle.module)

        #expect(throws: ScreenDocumentSourceError.resourceNotFound("does-not-exist")) {
            try source.loadDocument(named: "does-not-exist")
        }
    }

    @Test("reports malformed document data")
    @MainActor
    func reportsMalformedResource() {
        let source = BundleScreenDocumentSource(bundle: Bundle.module)

        #expect(throws: ScreenDocumentSourceError.self) {
            try source.loadDocument(named: "source-malformed")
        }
    }
}
