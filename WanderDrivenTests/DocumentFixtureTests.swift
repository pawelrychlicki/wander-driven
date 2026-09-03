import Foundation
import ServerDrivenKit
import Testing
@testable import WanderDriven

struct DocumentFixtureTests {
    @Test("decodes and validates the Discover and Lisbon fixtures")
    @MainActor
    func validatesPrimaryFixtures() throws {
        let source = BundleScreenDocumentSource(bundle: Bundle(for: AppBundleToken.self))
        let validator = DocumentValidator()

        for name in ["discover", "destination-lisbon"] {
            let document = try source.loadDocument(named: name)
            #expect(validator.validate(document).isEmpty)
        }
    }

    @Test("keeps valid Diagnostics Lab siblings visible beside fallbacks")
    @MainActor
    func containsDiagnostics() throws {
        let source = BundleScreenDocumentSource(bundle: Bundle(for: AppBundleToken.self))
        let document = try source.loadDocument(named: "diagnostics-lab")
        let registry = try AppComponentRegistry.make()
        let nodes = document.root.children
        guard let unknown = nodes.first(where: { $0.id == "diagnostics-unknown" }),
              let invalid = nodes.first(where: { $0.id == "diagnostics-invalid-properties" }),
              let valid = nodes.first(where: { $0.id == "diagnostics-valid-sibling" })
        else {
            Issue.record("Diagnostics fixture is missing one of its expected nodes.")
            return
        }

        #expect(DocumentValidator().validate(document).isEmpty)
        #expect(
            registry.resolve(
                unknown,
                context: ComponentContext(componentID: "diagnostics-unknown")
            ).isUnsupported
        )
        #expect(
            registry.resolve(
                invalid,
                context: ComponentContext(componentID: "diagnostics-invalid-properties")
            ).isInvalidProperties
        )
        #expect(
            registry.resolve(
                valid,
                context: ComponentContext(componentID: "diagnostics-valid-sibling")
            ).isRendered
        )
    }
}

private extension ResolvedComponent {
    var isRendered: Bool {
        guard case .rendered = self else {
            return false
        }
        return true
    }

    var isUnsupported: Bool {
        guard case .unsupported = self else {
            return false
        }
        return true
    }

    var isInvalidProperties: Bool {
        guard case .invalidProperties = self else {
            return false
        }
        return true
    }
}
