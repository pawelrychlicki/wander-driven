import SwiftUI

public struct UnsupportedComponentView: View {
    private let diagnostic: RenderDiagnostic
    private let policy: DiagnosticPolicy

    public init(
        diagnostic: RenderDiagnostic,
        policy: DiagnosticPolicy
    ) {
        self.diagnostic = diagnostic
        self.policy = policy
    }

    public var body: some View {
        Label {
            Text(policy.message(for: diagnostic))
        } icon: {
            Image(systemName: "questionmark.square.dashed")
        }
        .foregroundStyle(.secondary)
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(.secondary.opacity(0.08), in: .rect(cornerRadius: 12))
        .accessibilityElement(children: .combine)
        .accessibilityLabel(policy.message(for: diagnostic))
    }
}

public struct InvalidComponentView: View {
    private let diagnostic: RenderDiagnostic
    private let policy: DiagnosticPolicy

    public init(
        diagnostic: RenderDiagnostic,
        policy: DiagnosticPolicy
    ) {
        self.diagnostic = diagnostic
        self.policy = policy
    }

    public var body: some View {
        Label {
            Text(policy.message(for: diagnostic))
        } icon: {
            Image(systemName: "exclamationmark.triangle")
        }
        .foregroundStyle(.orange)
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(.orange.opacity(0.1), in: .rect(cornerRadius: 12))
        .accessibilityElement(children: .combine)
        .accessibilityLabel(policy.message(for: diagnostic))
    }
}
