import Testing
@testable import WanderDriven

@Test("application test target is wired")
func applicationTestTargetIsWired() {
    #expect(String(describing: type(of: RootView())).contains("RootView"))
}
