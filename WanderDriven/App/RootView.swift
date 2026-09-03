import SwiftUI

struct RootView: View {
    @State private var model: AppModel

    init(launchConfiguration: LaunchConfiguration = .current) {
        _model = State(
            initialValue: AppModel(initialRoute: launchConfiguration.initialRoute)
        )
    }

    var body: some View {
        ScenarioPickerView(model: model)
    }
}
