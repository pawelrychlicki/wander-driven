import ServerDrivenKit
import SwiftUI

struct ServerDrivenScreen: View {
    let model: AppModel
    let route: AppRoute

    var body: some View {
        Group {
            if case let .loaded(store)? = model.screen(for: route) {
                RenderedScreen(store: store, registry: model.registry)
            } else if case let .failed(loadError)? = model.screen(for: route) {
                ContentUnavailableView {
                    Label("Unable to load screen", systemImage: "exclamationmark.triangle")
                } description: {
                    Text(loadError)
                } actions: {
                    Button("Try again") {
                        model.retry(route: route)
                    }
                    .buttonStyle(.borderedProminent)
                }
                .padding()
            } else {
                ProgressView("Loading \(route.title)…")
                    .controlSize(.large)
            }
        }
        .navigationTitle(route.title)
        .navigationBarTitleDisplayMode(.inline)
        .safeAreaInset(edge: .bottom, spacing: 0) {
            if route == .diagnostics {
                DiagnosticsOverlay(policy: .current)
            }
        }
        .task(id: route) {
            model.prepareStore(for: route)
        }
    }
}

private struct RenderedScreen: View {
    let store: ScreenStore
    let registry: ComponentRegistry

    var body: some View {
        ScreenRenderer(registry: registry)
            .render(store.document, state: store.state, send: { componentID, action in
                store.send(.document(componentID: componentID, action: action))
            })
            .padding(.vertical)
            .padding(.horizontal)
            .alert(
                item: Binding(
                    get: { store.state.presentedAlert },
                    set: { _ in store.send(.dismissAlert) }
                )
            ) { alert in
                Alert(
                    title: Text(alert.title),
                    message: Text(alert.message),
                    dismissButton: .default(Text("OK"))
                )
            }
    }
}
