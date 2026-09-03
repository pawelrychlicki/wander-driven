import ServerDrivenKit
import SwiftUI

@SDUIComponent("badge")
struct Badge: ComponentDefinition {
    nonisolated struct Properties: Decodable, Sendable, Equatable {
        let text: String
        let tone: BadgeTone

        init(text: String, tone: BadgeTone = .neutral) {
            self.text = text
            self.tone = tone
        }

        private enum CodingKeys: String, CodingKey {
            case text
            case tone
        }

        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            text = try container.decode(String.self, forKey: .text)
            tone = try container.decodeIfPresent(BadgeTone.self, forKey: .tone) ?? .neutral
        }
    }

    @MainActor
    static func makeView(
        properties: Properties,
        context _: ComponentContext
    ) -> some View {
        BadgeView(text: properties.text, tone: properties.tone)
    }
}

nonisolated enum BadgeTone: String, Codable, Sendable {
    case neutral
    case accent
    case success
    case warning

    @MainActor
    var color: Color {
        switch self {
        case .neutral:
            .secondary
        case .accent:
            .accentColor
        case .success:
            .green
        case .warning:
            .orange
        }
    }

    var systemImage: String {
        switch self {
        case .neutral:
            "circle"
        case .accent:
            "sparkles"
        case .success:
            "checkmark.circle"
        case .warning:
            "exclamationmark.circle"
        }
    }
}
