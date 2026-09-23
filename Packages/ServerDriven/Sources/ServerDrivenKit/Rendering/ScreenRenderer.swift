import SwiftUI

@MainActor
public struct ScreenRenderer {
    public let registry: ComponentRegistry
    public let diagnosticPolicy: DiagnosticPolicy

    public init(
        registry: ComponentRegistry,
        diagnosticPolicy: DiagnosticPolicy = .current
    ) {
        self.registry = registry
        self.diagnosticPolicy = diagnosticPolicy
    }

    public func render(_ document: ScreenDocument) -> some View {
        render(document, send: { _ in })
    }

    public func render(
        _ document: ScreenDocument,
        send: @escaping @MainActor @Sendable (DocumentAction) -> Void
    ) -> some View {
        render(document, state: ScreenState(document: document)) { _, action in
            send(action)
        }
    }

    public func render(
        _ document: ScreenDocument,
        send: @escaping @MainActor @Sendable (ComponentID, DocumentAction) -> Void
    ) -> some View {
        render(document, state: ScreenState(document: document), send: send)
    }

    public func render(
        _ document: ScreenDocument,
        state: ScreenState,
        send: @escaping @MainActor @Sendable (DocumentAction) -> Void
    ) -> some View {
        render(document, state: state) { _, action in
            send(action)
        }
    }

    public func render(
        _ document: ScreenDocument,
        state: ScreenState,
        send: @escaping @MainActor @Sendable (ComponentID, DocumentAction) -> Void
    ) -> some View {
        ScreenNodeView(
            node: document.root,
            state: state,
            registry: registry,
            diagnosticPolicy: diagnosticPolicy,
            send: send
        )
    }
}
