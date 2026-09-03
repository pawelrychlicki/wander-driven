import Testing
@testable import ServerDrivenKit

@Test("macro target is part of the package test graph")
func macroTargetIsAvailable() {
    #expect(ServerDrivenKit.version.isEmpty == false)
}
