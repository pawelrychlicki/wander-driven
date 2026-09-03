import Foundation
import SwiftUI

public enum ComponentRegistrationError: Error, Equatable, Sendable {
    case wrongComponentType(expected: String, actual: String)
    case invalidProperties(componentType: String, message: String)
}

/// Type erasure used only at the runtime boundary where a JSON type selects a view.
@MainActor
public struct AnyComponentRegistration {
    public let componentType: String

    private let render: (JSONValue, ComponentContext) throws -> AnyView

    public init<Definition: ComponentDefinition>(_ definition: Definition.Type) {
        componentType = Definition.componentType
        render = { properties, context in
            do {
                let encodedProperties = try JSONEncoder().encode(properties)
                let decodedProperties = try JSONDecoder().decode(
                    Definition.Properties.self,
                    from: encodedProperties
                )
                return AnyView(
                    Definition.makeView(
                        properties: decodedProperties,
                        context: context
                    )
                )
            } catch {
                throw ComponentRegistrationError.invalidProperties(
                    componentType: Definition.componentType,
                    message: String(describing: error)
                )
            }
        }
    }

    public func makeView(
        properties: JSONValue,
        context: ComponentContext
    ) throws -> AnyView {
        try render(properties, context)
    }

    public func makeView(
        for node: ScreenNode,
        context: ComponentContext
    ) throws -> AnyView {
        guard node.type == componentType else {
            throw ComponentRegistrationError.wrongComponentType(
                expected: componentType,
                actual: node.type
            )
        }

        return try makeView(properties: node.properties, context: context)
    }
}
