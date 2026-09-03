import SwiftUI

struct BadgeView: View {
    let text: String
    let tone: BadgeTone
    let accessibilityIdentifier: String?

    init(
        text: String,
        tone: BadgeTone,
        accessibilityIdentifier: String? = nil
    ) {
        self.text = text
        self.tone = tone
        self.accessibilityIdentifier = accessibilityIdentifier
    }

    var body: some View {
        Label(text, systemImage: tone.systemImage)
            .font(.caption.weight(.semibold))
            .foregroundStyle(tone.color)
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(tone.color.opacity(0.12), in: Capsule())
            .accessibilityElement(children: .combine)
            .accessibilityLabel(text)
            .accessibilityIdentifier(accessibilityIdentifier ?? "")
    }
}
