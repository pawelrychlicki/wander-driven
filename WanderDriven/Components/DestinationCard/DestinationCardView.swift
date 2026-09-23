import ServerDrivenKit
import SwiftUI

struct DestinationCardView: View {
    let componentID: ComponentID
    let properties: DestinationCard.Properties
    let isFavorite: Bool
    let onFavorite: (@MainActor @Sendable () -> Void)?
    let onSelect: (@MainActor @Sendable () -> Void)?

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            if let onSelect {
                Button(action: onSelect) {
                    content
                }
                .buttonStyle(.plain)
                .accessibilityIdentifier("sdui.\(componentID.rawValue).open")
                .accessibilityLabel("Open \(properties.name), \(properties.country)")
                .accessibilityHint("Shows destination details")
            } else {
                content
            }

            HStack(spacing: 12) {
                BadgeView(
                    text: "Curated",
                    tone: .accent
                )

                if let onFavorite {
                    Spacer(minLength: 8)

                    Button(action: onFavorite) {
                        Label(
                            isFavorite ? "Remove favorite" : "Add favorite",
                            systemImage: isFavorite ? "heart.fill" : "heart"
                        )
                    }
                    .buttonStyle(.bordered)
                    .frame(minWidth: 44, minHeight: 44)
                    .accessibilityIdentifier("sdui.\(componentID.rawValue).favorite")
                    .accessibilityValue(isFavorite ? "Favorite" : "Not a favorite")
                }
            }
        }
        .padding(20)
        .background(.thinMaterial, in: .rect(cornerRadius: 22))
        .overlay {
            RoundedRectangle(cornerRadius: 22)
                .strokeBorder(.quaternary, lineWidth: 1)
        }
        .accessibilityElement(children: .contain)
    }

    private var content: some View {
        VStack(alignment: .leading, spacing: 12) {
            Image(systemName: properties.imageSystemName)
                .font(.system(size: 42, weight: .medium))
                .foregroundStyle(.tint)
                .frame(maxWidth: .infinity, minHeight: 72, alignment: .leading)
                .accessibilityHidden(true)

            VStack(alignment: .leading, spacing: 4) {
                Text(properties.name)
                    .font(.title2.weight(.semibold))
                    .foregroundStyle(.primary)
                Text(properties.country)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            Text(properties.summary)
                .font(.body)
                .foregroundStyle(.primary)
                .multilineTextAlignment(.leading)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .contentShape(.rect)
    }
}
