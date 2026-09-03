import ServerDrivenKit

enum AppRoute: Hashable, Identifiable, Sendable {
    case discover
    case destination(ComponentID)
    case diagnostics

    static let scenarios: [AppRoute] = [
        .discover,
        .destination("lisbon"),
        .diagnostics,
    ]

    var id: String {
        switch self {
        case .discover:
            "discover"
        case let .destination(destinationID):
            "destination-\(destinationID.rawValue)"
        case .diagnostics:
            "diagnostics-lab"
        }
    }

    var title: String {
        switch self {
        case .discover:
            "Discover"
        case .destination:
            "Destination Details"
        case .diagnostics:
            "Diagnostics Lab"
        }
    }

    var subtitle: String {
        switch self {
        case .discover:
            "Browse a server-driven travel feed"
        case .destination:
            "Compose a destination from reusable components"
        case .diagnostics:
            "See resilient rendering with malformed content"
        }
    }

    var systemImage: String {
        switch self {
        case .discover:
            "safari"
        case .destination:
            "mappin.and.ellipse"
        case .diagnostics:
            "ladybug"
        }
    }

    var documentResourceName: String {
        switch self {
        case .discover:
            "discover"
        case let .destination(destinationID):
            "destination-\(destinationID.rawValue)"
        case .diagnostics:
            "diagnostics-lab"
        }
    }
}
