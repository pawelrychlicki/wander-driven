import SwiftUI

public protocol ComponentDefinition {
    associatedtype Properties: Decodable & Sendable
    associatedtype Content: View

    static var componentType: String { get }

    @MainActor
    static func makeView(
        properties: Properties,
        context: ComponentContext
    ) -> Content
}

public extension ComponentDefinition {
    @MainActor
    static var registration: AnyComponentRegistration {
        AnyComponentRegistration(Self.self)
    }
}
