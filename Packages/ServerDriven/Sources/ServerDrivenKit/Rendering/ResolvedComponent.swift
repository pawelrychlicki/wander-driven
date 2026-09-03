import SwiftUI

@MainActor
public enum ResolvedComponent {
    case rendered(AnyView)
    case unsupported(RenderDiagnostic)
    case invalidProperties(RenderDiagnostic)
}
