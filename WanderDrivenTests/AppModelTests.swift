import ServerDrivenKit
import Testing
@testable import WanderDriven

struct AppModelTests {
    @Test("keeps a load failure scoped to its route and retries it")
    @MainActor
    func isolatesRouteFailures() {
        let source = ControllableDocumentSource(failingNames: ["discover"])
        let model = AppModel(documentSource: source)

        model.prepareStore(for: .discover)
        model.prepareStore(for: .destination("lisbon"))

        guard case .failed = model.screen(for: .discover) else {
            Issue.record("Discover should retain its own load failure.")
            return
        }
        guard case .loaded = model.screen(for: .destination("lisbon")) else {
            Issue.record("Destination should load despite another route's failure.")
            return
        }

        source.failingNames.remove("discover")
        model.retry(route: .discover)

        guard case .loaded = model.screen(for: .discover) else {
            Issue.record("Retry should replace the failed route with a loaded store.")
            return
        }
    }
}

@MainActor
private final class ControllableDocumentSource: ScreenDocumentSource {
    var failingNames: Set<String>

    init(failingNames: Set<String>) {
        self.failingNames = failingNames
    }

    func loadDocument(named name: String) throws -> ScreenDocument {
        if failingNames.contains(name) {
            throw ScreenDocumentSourceError.resourceNotFound(name)
        }
        return ScreenDocument(
            schemaVersion: 1,
            root: ScreenNode(id: "root", type: "vertical")
        )
    }
}
