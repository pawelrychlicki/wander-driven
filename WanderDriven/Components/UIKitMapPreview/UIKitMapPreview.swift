import CoreLocation
import ServerDrivenKit
import SwiftUI

@SDUIComponent("map.preview")
struct UIKitMapPreview: ComponentDefinition {
    nonisolated struct Properties: Decodable, Sendable, Equatable {
        let city: String
        let latitude: Double
        let longitude: Double

        init(city: String, latitude: Double, longitude: Double) {
            self.city = city
            self.latitude = latitude
            self.longitude = longitude
        }
    }

    @MainActor
    static func makeView(
        properties: Properties,
        context _: ComponentContext
    ) -> some View {
        UIKitMapPreviewRepresentable(
            city: properties.city,
            coordinate: CLLocationCoordinate2D(
                latitude: properties.latitude,
                longitude: properties.longitude
            )
        )
        .frame(minHeight: 180)
        .clipShape(.rect(cornerRadius: 20))
    }
}
