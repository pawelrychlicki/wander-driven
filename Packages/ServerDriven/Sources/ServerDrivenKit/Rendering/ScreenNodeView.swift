import SwiftUI

/// Recursion lives in a concrete view, preserving node identity in ForEach.
/// Only registered leaf components need type erasure at the registry boundary.
@MainActor
struct ScreenNodeView: View {
    let node: ScreenNode
    let state: ScreenState
    let registry: ComponentRegistry
    let diagnosticPolicy: DiagnosticPolicy
    let send: @MainActor @Sendable (ComponentID, DocumentAction) -> Void

    var body: some View {
        switch node.type {
        case "vertical":
            VStack(alignment: .leading, spacing: spacing) {
                children
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        case "horizontal":
            HStack(alignment: .top, spacing: spacing) {
                children
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        case "scroll":
            ScrollView(.vertical) {
                LazyVStack(alignment: .leading, spacing: spacing) {
                    children
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal)
            }
            .scrollEdgeEffectStyle(.soft, for: .top)
        default:
            component
        }
    }

    private var children: some View {
        ForEach(node.children) { child in
            ScreenNodeView(
                node: child,
                state: state,
                registry: registry,
                diagnosticPolicy: diagnosticPolicy,
                send: send
            )
        }
    }

    @ViewBuilder
    private var component: some View {
        let context = ComponentContext(
            componentID: node.id,
            actions: node.actions,
            state: state[node.id],
            send: { action in send(node.id, action) }
        )

        switch registry.resolve(node, context: context) {
        case let .rendered(view):
            view
        case let .unsupported(diagnostic):
            UnsupportedComponentView(diagnostic: diagnostic, policy: diagnosticPolicy)
        case let .invalidProperties(diagnostic):
            InvalidComponentView(diagnostic: diagnostic, policy: diagnosticPolicy)
        }
    }

    private var spacing: CGFloat {
        guard case let .object(values) = node.properties,
              case let .number(value) = values["spacing"]
        else {
            return 16
        }

        return max(0, min(value, 64))
    }
}
