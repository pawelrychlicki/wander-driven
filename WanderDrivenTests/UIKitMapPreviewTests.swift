import CoreLocation
import Testing
@testable import WanderDriven

struct UIKitMapPreviewTests {
    @Test("updates the UIKit preview view through its representable model")
    @MainActor
    func updatesUIKitView() {
        let view = UIKitMapPreviewView(
            city: "Lisbon",
            coordinate: CLLocationCoordinate2D(latitude: 38.7223, longitude: -9.1393)
        )

        view.update(
            city: "Porto",
            coordinate: CLLocationCoordinate2D(latitude: 41.1579, longitude: -8.6291)
        )

        #expect(view.city == "Porto")
        #expect(view.coordinate.latitude == 41.1579)
        #expect(view.coordinate.longitude == -8.6291)
        #expect(view.accessibilityLabel?.contains("Porto") == true)
    }

    @Test("exposes map preview registration in the explicit app registry")
    @MainActor
    func registersMapPreview() throws {
        let registry = try AppComponentRegistry.make()

        #expect(registry.registration(for: "map.preview") != nil)
    }
}
