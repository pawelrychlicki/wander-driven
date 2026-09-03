@testable import ServerDrivenKit
import Testing

@Test("macro target is part of the package test graph")
func macroTargetIsAvailable() {
    #expect(ServerDrivenKit.version.isEmpty == false)
}
