import Observation
import ServerDrivenKit

@MainActor
@Observable
final class AppModel {
    let registry: ComponentRegistry
    let documentSource: any ScreenDocumentSource
    let validator: DocumentValidator

    var navigationPath: [AppRoute] = []
    private(set) var loadError: String?
    private(set) var storeRevision = 0

    @ObservationIgnored
    private var stores: [AppRoute: ScreenStore] = [:]

    init(
        documentSource: any ScreenDocumentSource = BundleScreenDocumentSource(),
        validator: DocumentValidator = DocumentValidator(),
        registry: ComponentRegistry? = nil,
        initialRoute: AppRoute? = nil
    ) {
        self.documentSource = documentSource
        self.validator = validator
        self.registry = registry ?? Self.makeDefaultRegistry()
        if let initialRoute {
            navigationPath = [initialRoute]
        }
    }

    func prepareStore(for route: AppRoute) {
        guard stores[route] == nil else {
            return
        }

        do {
            let document = try documentSource.loadDocument(
                named: route.documentResourceName
            )
            let issues = validator.validate(document)
            guard issues.isEmpty else {
                loadError = issues.map(\.message).joined(separator: "\n")
                return
            }

            stores[route] = ScreenStore(
                document: document,
                externalActionHandler: ExternalActionHandler { [weak self] action in
                    self?.handleExternalAction(action)
                }
            )
            storeRevision += 1
            loadError = nil
        } catch {
            loadError = String(describing: error)
            storeRevision += 1
        }
    }

    func store(for route: AppRoute) -> ScreenStore? {
        stores[route]
    }

    func retry(route: AppRoute) {
        stores[route] = nil
        storeRevision += 1
        loadError = nil
        prepareStore(for: route)
    }

    private func handleExternalAction(_ action: ExternalAction) {
        switch action {
        case let .navigate(destinationID):
            navigationPath.append(.destination(destinationID))
        case .custom:
            break
        }
    }

    private static func makeDefaultRegistry() -> ComponentRegistry {
        do {
            return try AppComponentRegistry.make()
        } catch {
            preconditionFailure("Default component registration is invalid: \(error)")
        }
    }
}
