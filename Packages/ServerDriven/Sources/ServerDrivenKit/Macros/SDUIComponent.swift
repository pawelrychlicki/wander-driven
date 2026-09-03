@attached(member, names: named(componentType), named(registration))
public macro SDUIComponent(_ identifier: String) =
    #externalMacro(module: "ServerDrivenMacros", type: "SDUIComponentMacro")
