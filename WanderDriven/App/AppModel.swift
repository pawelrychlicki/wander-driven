import Observation
import ServerDrivenKit

enum ScreenLoadState {
    case loaded(ScreenStore)
    case failed(String)
}

@MainActor
@Observable
final class AppModel {
    let registry: ComponentRegistry
    let documentSource: any ScreenDocumentSource
    let validator: DocumentValidator

    var navigationPath: [AppRoute] = []
    private(set) var screens: [AppRoute: ScreenLoadState] = [:]

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
        guard screens[route] == nil else {
            return
        }

        do {
            let document = try documentSource.loadDocument(
                named: route.documentResourceName
            )
            let issues = validator.validate(document)
            guard issues.isEmpty else {
                screens[route] = .failed(issues.map(\.message).joined(separator: "\n"))
                return
            }

            screens[route] = .loaded(ScreenStore(
                document: document,
                externalActionHandler: ExternalActionHandler { [weak self] action in
                    self?.handleExternalAction(action)
                }
            ))
        } catch {
            screens[route] = .failed(String(describing: error))
        }
    }

    func screen(for route: AppRoute) -> ScreenLoadState? {
        screens[route]
    }

    func retry(route: AppRoute) {
        screens[route] = nil
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
