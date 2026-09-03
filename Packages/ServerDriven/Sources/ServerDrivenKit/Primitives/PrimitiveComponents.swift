import SwiftUI

@SDUIComponent("text")
public struct TextComponent: ComponentDefinition {
    public enum TextStyle: String, Codable, Sendable {
        case largeTitle
        case title
        case headline
        case body
        case caption

        @MainActor
        var font: Font {
            switch self {
            case .largeTitle:
                .largeTitle
            case .title:
                .title
            case .headline:
                .headline
            case .body:
                .body
            case .caption:
                .caption
            }
        }
    }

    public struct Properties: Decodable, Sendable {
        public let text: String
        public let style: TextStyle

        public init(text: String, style: TextStyle = .body) {
            self.text = text
            self.style = style
        }
    }

    @MainActor
    public static func makeView(
        properties: Properties,
        context _: ComponentContext
    ) -> some View {
        Text(properties.text)
            .font(properties.style.font)
            .foregroundStyle(.primary)
            .multilineTextAlignment(.leading)
            .frame(maxWidth: .infinity, alignment: .leading)
    }
}

@SDUIComponent("image")
public struct ImageComponent: ComponentDefinition {
    public struct Properties: Decodable, Sendable {
        public let systemName: String
        public let accessibilityLabel: String?

        public init(systemName: String, accessibilityLabel: String? = nil) {
            self.systemName = systemName
            self.accessibilityLabel = accessibilityLabel
        }
    }

    @MainActor
    public static func makeView(
        properties: Properties,
        context _: ComponentContext
    ) -> some View {
        Image(systemName: properties.systemName)
            .resizable()
            .scaledToFit()
            .frame(maxWidth: .infinity)
            .frame(minHeight: 44)
            .foregroundStyle(.tint)
            .accessibilityLabel(
                properties.accessibilityLabel ?? properties.systemName
            )
    }
}

@SDUIComponent("button")
public struct ButtonComponent: ComponentDefinition {
    public struct Properties: Decodable, Sendable {
        public let title: String

        public init(title: String) {
            self.title = title
        }
    }

    @MainActor
    public static func makeView(
        properties: Properties,
        context: ComponentContext
    ) -> some View {
        Button(properties.title) {
            guard let action = context.actions.first else {
                return
            }
            context.send(action)
        }
        .buttonStyle(.borderedProminent)
        .frame(minWidth: 44, minHeight: 44)
        .accessibilityLabel(properties.title)
    }
}

@SDUIComponent("divider")
public struct DividerComponent: ComponentDefinition {
    public struct Properties: Decodable, Sendable {
        public init() {}
    }

    @MainActor
    public static func makeView(
        properties _: Properties,
        context _: ComponentContext
    ) -> some View {
        Divider()
            .padding(.vertical, 8)
    }
}
