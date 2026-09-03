/// Small, dependency-free launch configuration used by UI tests and previews.
struct LaunchConfiguration: Sendable {
    let initialRoute: AppRoute?

    init(arguments: [String]) {
        guard let flagIndex = arguments.firstIndex(of: "-uiTestScenario"),
              arguments.indices.contains(flagIndex + 1)
        else {
            initialRoute = nil
            return
        }

        switch arguments[flagIndex + 1] {
        case "discover":
            initialRoute = .discover
        case "destination-lisbon":
            initialRoute = .destination("lisbon")
        case "diagnostics":
            initialRoute = .diagnostics
        default:
            initialRoute = nil
        }
    }

    static var current: Self {
        Self(arguments: CommandLine.arguments)
    }
}
