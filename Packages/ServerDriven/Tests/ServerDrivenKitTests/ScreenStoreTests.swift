@testable import ServerDrivenKit
import Testing

struct ScreenStoreTests {
    @Test("forwards navigation actions to the host handler")
    @MainActor
    func forwardsNavigation() {
        let recorder = ExternalActionRecorder()
        let store = ScreenStore(
            document: makeDocument(),
            externalActionHandler: ExternalActionHandler { [recorder] action in
                recorder.actions.append(action)
            }
        )

        store.send(
            .document(
                componentID: "open-lisbon",
                action: DocumentAction(
                    type: "navigate",
                    payload: .object(["destinationID": .string("lisbon")])
                )
            )
        )

        #expect(recorder.actions == [.navigate(destinationID: "lisbon")])
    }

    @Test("dispatches effect results back through the reducer")
    @MainActor
    func dispatchesEffectResult() async {
        let executor = ScreenEffectExecutor { _ in
            .success(.value(.string("loaded")))
        }
        let store = ScreenStore(
            document: makeDocument(),
            effectExecutor: executor
        )
        let request = ScreenEffectRequest(id: "load", kind: .load("discover"))

        store.send(.startEffect(request))
        await waitUntilEffectCompleted(store)

        #expect(
            store.state.lastEffectResult ==
                .success(.value(.string("loaded")))
        )
        #expect(store.state.activeEffectIDs.isEmpty)
    }

    @Test("cancels an in-flight effect and drops its late result")
    @MainActor
    func cancelsInFlightEffect() async {
        let gate = BlockingEffect()
        let executor = ScreenEffectExecutor { _ in
            await gate.run()
        }
        let store = ScreenStore(
            document: makeDocument(),
            effectExecutor: executor
        )
        let request = ScreenEffectRequest(id: "slow-load", kind: .load("discover"))

        store.send(.startEffect(request))
        await waitUntilStarted(gate)
        store.send(.cancelEffect(id: request.id))
        await gate.resume(.success(.completed))
        await Task.yield()

        #expect(store.state.activeEffectIDs.isEmpty)
        #expect(store.state.lastEffectResult == nil)
    }

    @Test("keeps normalized state when a store is reconstructed for the same document")
    @MainActor
    func preservesStateAcrossReconstruction() {
        let document = makeDocument()
        let firstStore = ScreenStore(document: document)
        firstStore.send(
            .document(
                componentID: "favorite-button",
                action: DocumentAction(
                    type: "toggleFavorite",
                    payload: .object(["destinationID": .string("lisbon")])
                )
            )
        )

        let reconstructedStore = ScreenStore(
            document: document,
            initialState: firstStore.state
        )

        #expect(reconstructedStore.document == document)
        #expect(reconstructedStore.state.componentStates["lisbon"]?.isFavorite == true)
    }

    @MainActor
    private func waitUntilStarted(_ gate: BlockingEffect) async {
        for _ in 0 ..< 100 {
            if await gate.isStarted() {
                return
            }
            await Task.yield()
        }
        Issue.record("The controlled effect did not start in time.")
    }

    @MainActor
    private func waitUntilEffectCompleted(_ store: ScreenStore) async {
        for _ in 0 ..< 100 {
            if store.state.lastEffectResult != nil {
                return
            }
            await Task.yield()
        }
        Issue.record("The controlled effect did not complete in time.")
    }

    private func makeDocument() -> ScreenDocument {
        ScreenDocument(
            schemaVersion: 1,
            root: ScreenNode(
                id: "root",
                type: "vertical",
                children: [
                    ScreenNode(id: "lisbon", type: "destination.card"),
                    ScreenNode(id: "open-lisbon", type: "button"),
                ]
            )
        )
    }
}

@MainActor
private final class ExternalActionRecorder {
    var actions: [ExternalAction] = []
}

private actor BlockingEffect {
    private var continuation: CheckedContinuation<ScreenEffectResult, Never>?
    private var started = false

    func run() async -> ScreenEffectResult {
        started = true
        return await withCheckedContinuation { continuation in
            self.continuation = continuation
        }
    }

    func isStarted() -> Bool {
        started
    }

    func resume(_ result: ScreenEffectResult) {
        continuation?.resume(returning: result)
        continuation = nil
    }
}
