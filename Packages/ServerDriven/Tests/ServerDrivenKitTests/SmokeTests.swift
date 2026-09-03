import Testing
@testable import ServerDrivenKit

@Test("ServerDrivenKit exposes its package version")
func packageVersionIsAvailable() {
    #expect(ServerDrivenKit.version == "0.1.0")
}
