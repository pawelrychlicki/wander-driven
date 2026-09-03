import ServerDrivenKit
import SwiftUI

struct ServerDrivenScreen: View {
    let model: AppModel
    let route: AppRoute

    var body: some View {
        Group {
            if let store = model.store(for: route) {
                ScreenRenderer(registry: model.registry)
                    .render(store.document, state: store.state, send: { componentID, action in
                        store.send(
                            .document(componentID: componentID, action: action)
                        )
                    })
                    .id(store.stateRevision)
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
            } else if let loadError = model.loadError {
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
        .id(model.storeRevision)
        .navigationTitle(route.title)
        .navigationBarTitleDisplayMode(.inline)
        .safeAreaInset(edge: .bottom, spacing: 0) {
            if route == .diagnostics {
                DiagnosticsOverlay(policy: .debug)
            }
        }
        .task(id: route) {
            model.prepareStore(for: route)
        }
    }
}
