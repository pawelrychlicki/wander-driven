import SwiftUI

struct ScenarioPickerView: View {
    @Bindable var model: AppModel

    var body: some View {
        NavigationStack(path: $model.navigationPath) {
            List {
                Section {
                    ForEach(AppRoute.scenarios) { route in
                        NavigationLink(value: route) {
                            Label {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(route.title)
                                        .font(.headline)
                                    Text(route.subtitle)
                                        .font(.subheadline)
                                        .foregroundStyle(.secondary)
                                }
                            } icon: {
                                Image(systemName: route.systemImage)
                                    .foregroundStyle(.tint)
                            }
                        }
                        .accessibilityHint("Opens the \(route.title) scenario")
                        .accessibilityIdentifier("scenario.\(route.id)")
                    }
                } header: {
                    Text("Travel scenarios")
                } footer: {
                    Text("Every screen is described by a local JSON document and rendered by ServerDrivenKit.")
                }
            }
            .listStyle(.insetGrouped)
            .navigationTitle("WanderDriven")
            .navigationDestination(for: AppRoute.self) { route in
                ServerDrivenScreen(model: model, route: route)
            }
        }
    }
}
