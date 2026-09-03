import ServerDrivenKit
import SwiftUI

struct DiagnosticsOverlay: View {
    let policy: DiagnosticPolicy

    var body: some View {
        Label {
            Text(message)
        } icon: {
            Image(systemName: "ladybug")
        }
        .font(.footnote.weight(.medium))
        .foregroundStyle(.secondary)
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal)
        .padding(.vertical, 10)
        .background(.bar)
        .accessibilityElement(children: .combine)
        .accessibilityIdentifier("diagnostics.overlay")
    }

    private var message: String {
        switch policy {
        case .debug:
            "Debug diagnostics are visible for this scenario."
        case .release:
            "Fallback content is presented safely."
        }
    }
}
