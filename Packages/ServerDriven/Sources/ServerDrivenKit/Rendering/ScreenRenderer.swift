import SwiftUI

@MainActor
public struct ScreenRenderer {
    public let registry: ComponentRegistry
    public let diagnosticPolicy: DiagnosticPolicy

    public init(
        registry: ComponentRegistry,
        diagnosticPolicy: DiagnosticPolicy = .debug
    ) {
        self.registry = registry
        self.diagnosticPolicy = diagnosticPolicy
    }

    public func render(
        _ document: ScreenDocument,
        send: @escaping @MainActor @Sendable (DocumentAction) -> Void = { _ in }
    ) -> AnyView {
        renderNode(document.root, send: send)
    }

    private func renderNode(
        _ node: ScreenNode,
        send: @escaping @MainActor @Sendable (DocumentAction) -> Void
    ) -> AnyView {
        let context = ComponentContext(
            componentID: node.id,
            actions: node.actions,
            send: send
        )

        switch node.type {
        case "vertical":
            return AnyView(
                VStack(alignment: .leading, spacing: spacing(from: node)) {
                    renderChildren(node.children, send: send)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            )
        case "horizontal":
            return AnyView(
                HStack(alignment: .top, spacing: spacing(from: node)) {
                    renderChildren(node.children, send: send)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            )
        case "scroll":
            return AnyView(
                ScrollView(.vertical) {
                    LazyVStack(alignment: .leading, spacing: spacing(from: node)) {
                        renderChildren(node.children, send: send)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal)
                }
                .scrollEdgeEffectStyle(.soft, for: .top)
            )
        default:
            switch registry.resolve(node, context: context) {
            case let .rendered(view):
                return view
            case let .unsupported(diagnostic):
                return AnyView(
                    UnsupportedComponentView(
                        diagnostic: diagnostic,
                        policy: diagnosticPolicy
                    )
                )
            case let .invalidProperties(diagnostic):
                return AnyView(
                    InvalidComponentView(
                        diagnostic: diagnostic,
                        policy: diagnosticPolicy
                    )
                )
            }
        }
    }

    private func renderChildren(
        _ children: [ScreenNode],
        send: @escaping @MainActor @Sendable (DocumentAction) -> Void
    ) -> some View {
        ForEach(children) { child in
            renderNode(child, send: send)
        }
    }

    private func spacing(from node: ScreenNode) -> CGFloat {
        guard case let .object(values) = node.properties,
              case let .number(value) = values["spacing"]
        else {
            return 16
        }

        return max(0, min(value, 64))
    }
}
