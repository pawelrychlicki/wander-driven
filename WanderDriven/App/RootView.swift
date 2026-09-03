import SwiftUI

struct RootView: View {
    @State private var model = AppModel()

    var body: some View {
        ScenarioPickerView(model: model)
    }
}
