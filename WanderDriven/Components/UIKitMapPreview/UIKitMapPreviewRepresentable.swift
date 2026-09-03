import CoreLocation
import SwiftUI
import UIKit

struct UIKitMapPreviewRepresentable: UIViewRepresentable {
    let city: String
    let coordinate: CLLocationCoordinate2D

    func makeUIView(context _: Context) -> UIKitMapPreviewView {
        UIKitMapPreviewView(city: city, coordinate: coordinate)
    }

    func updateUIView(_ uiView: UIKitMapPreviewView, context _: Context) {
        uiView.update(city: city, coordinate: coordinate)
    }
}

@MainActor
final class UIKitMapPreviewView: UIView {
    private let cityLabel = UILabel()
    private let coordinatesLabel = UILabel()
    private let pinView = UIImageView(
        image: UIImage(systemName: "mappin.and.ellipse")
    )

    private(set) var city: String
    private(set) var coordinate: CLLocationCoordinate2D

    init(city: String, coordinate: CLLocationCoordinate2D) {
        self.city = city
        self.coordinate = coordinate
        super.init(frame: .zero)
        configureView()
        update(city: city, coordinate: coordinate)
    }

    required init?(coder: NSCoder) {
        city = ""
        coordinate = CLLocationCoordinate2D()
        super.init(coder: coder)
        configureView()
        update(city: city, coordinate: coordinate)
    }

    func update(city: String, coordinate: CLLocationCoordinate2D) {
        self.city = city
        self.coordinate = coordinate
        cityLabel.text = city
        coordinatesLabel.text = String(
            format: "%.4f, %.4f",
            coordinate.latitude,
            coordinate.longitude
        )
        accessibilityLabel = "Map preview for \(city)"
        accessibilityValue = coordinatesLabel.text
    }

    private func configureView() {
        backgroundColor = .secondarySystemBackground
        layer.cornerRadius = 20
        layer.cornerCurve = .continuous
        isAccessibilityElement = true

        pinView.tintColor = .systemBlue
        pinView.setContentHuggingPriority(.required, for: .horizontal)

        cityLabel.font = .preferredFont(forTextStyle: .headline)
        cityLabel.textColor = .label

        coordinatesLabel.font = .preferredFont(forTextStyle: .caption1)
        coordinatesLabel.textColor = .secondaryLabel

        let labels = UIStackView(arrangedSubviews: [cityLabel, coordinatesLabel])
        labels.axis = .vertical
        labels.spacing = 4

        let content = UIStackView(arrangedSubviews: [pinView, labels])
        content.axis = .horizontal
        content.alignment = .center
        content.spacing = 12

        addSubview(content)
        content.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            content.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            content.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),
            content.topAnchor.constraint(equalTo: topAnchor, constant: 20),
            content.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -20),
        ])
    }
}
