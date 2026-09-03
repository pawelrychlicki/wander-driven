import SwiftUI

struct RootView: View {
    var body: some View {
        ContentUnavailableView(
            "WanderDriven",
            systemImage: "airplane",
            description: Text("Server-driven travel experiences are coming soon.")
        )
        .navigationTitle("WanderDriven")
    }
}
