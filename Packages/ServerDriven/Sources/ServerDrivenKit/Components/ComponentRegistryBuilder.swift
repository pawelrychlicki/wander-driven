@resultBuilder
@MainActor
public enum ComponentRegistryBuilder {
    public static func buildBlock(
        _ components: AnyComponentRegistration...
    ) -> [AnyComponentRegistration] {
        Array(components)
    }

    public static func buildOptional(
        _ component: [AnyComponentRegistration]?
    ) -> [AnyComponentRegistration] {
        component ?? []
    }

    public static func buildEither(
        first component: [AnyComponentRegistration]
    ) -> [AnyComponentRegistration] {
        component
    }

    public static func buildEither(
        second component: [AnyComponentRegistration]
    ) -> [AnyComponentRegistration] {
        component
    }

    public static func buildArray(
        _ components: [[AnyComponentRegistration]]
    ) -> [AnyComponentRegistration] {
        components.flatMap { $0 }
    }
}
