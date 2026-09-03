import SwiftCompilerPlugin
import SwiftSyntaxMacros

@main
struct ServerDrivenPlugin: CompilerPlugin {
    let providingMacros: [Macro.Type] = [SDUIComponentMacro.self]
}
