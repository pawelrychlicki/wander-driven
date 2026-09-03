import SwiftUI

public enum ComponentRegistryError: Error, Equatable, Sendable {
    case duplicateComponentType(String)
}

@MainActor
public struct ComponentRegistry {
    private let registrations: [String: AnyComponentRegistration]

    public init(
        @ComponentRegistryBuilder _ content: () -> [AnyComponentRegistration]
    ) throws {
        try self.init(content())
    }

    public init(_ registrations: [AnyComponentRegistration]) throws {
        var values: [String: AnyComponentRegistration] = [:]
        values.reserveCapacity(registrations.count)

        for registration in registrations {
            guard values[registration.componentType] == nil else {
                throw ComponentRegistryError.duplicateComponentType(
                    registration.componentType
                )
            }
            values[registration.componentType] = registration
        }

        self.registrations = values
    }

    public func registration(for componentType: String) -> AnyComponentRegistration? {
        registrations[componentType]
    }

    public func makeView(
        for node: ScreenNode,
        context: ComponentContext
    ) throws -> AnyView {
        guard let registration = registration(for: node.type) else {
            throw ComponentRegistrationError.wrongComponentType(
                expected: node.type,
                actual: node.type
            )
        }

        return try registration.makeView(for: node, context: context)
    }
}
