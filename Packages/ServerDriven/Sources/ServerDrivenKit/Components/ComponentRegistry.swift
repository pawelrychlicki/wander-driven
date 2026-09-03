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
            throw ComponentRegistrationError.unknownComponentType(node.type)
        }

        return try registration.makeView(for: node, context: context)
    }

    public func resolve(
        _ node: ScreenNode,
        context: ComponentContext
    ) -> ResolvedComponent {
        guard let registration = registration(for: node.type) else {
            return .unsupported(
                RenderDiagnostic(
                    code: .unsupportedComponent,
                    componentID: node.id,
                    componentType: node.type,
                    detail: "No registration exists for component type '\(node.type)'."
                )
            )
        }

        do {
            return try .rendered(registration.makeView(for: node, context: context))
        } catch let error as ComponentRegistrationError {
            switch error {
            case let .invalidProperties(componentType, message):
                return .invalidProperties(
                    RenderDiagnostic(
                        code: .invalidProperties,
                        componentID: node.id,
                        componentType: componentType,
                        detail: message
                    )
                )
            case let .wrongComponentType(expected, actual):
                return .invalidProperties(
                    RenderDiagnostic(
                        code: .invalidProperties,
                        componentID: node.id,
                        componentType: expected,
                        detail: "Expected component type '\(expected)' but received '\(actual)'."
                    )
                )
            case let .unknownComponentType(componentType):
                return .unsupported(
                    RenderDiagnostic(
                        code: .unsupportedComponent,
                        componentID: node.id,
                        componentType: componentType,
                        detail: "No registration exists for component type '\(componentType)'."
                    )
                )
            }
        } catch {
            return .invalidProperties(
                RenderDiagnostic(
                    code: .invalidProperties,
                    componentID: node.id,
                    componentType: node.type,
                    detail: String(describing: error)
                )
            )
        }
    }
}
