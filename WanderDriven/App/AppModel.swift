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

    @ObservationIgnored
    private var stores: [AppRoute: ScreenStore] = [:]

    init(
        documentSource: any ScreenDocumentSource = BundleScreenDocumentSource(),
        validator: DocumentValidator = DocumentValidator(),
        registry: ComponentRegistry? = nil
    ) {
        self.documentSource = documentSource
        self.validator = validator
        self.registry = registry ?? Self.makeDefaultRegistry()
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
            loadError = nil
        } catch {
            loadError = String(describing: error)
        }
    }

    func store(for route: AppRoute) -> ScreenStore? {
        stores[route]
    }

    func retry(route: AppRoute) {
        stores[route] = nil
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
