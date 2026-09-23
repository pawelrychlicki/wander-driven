import Observation

@MainActor
@Observable
public final class ScreenStore {
    public let document: ScreenDocument
    public private(set) var state: ScreenState
    public let reducer: ScreenReducer
    public let externalActionHandler: ExternalActionHandler
    public let effectExecutor: ScreenEffectExecutor

    @ObservationIgnored
    private var runningEffects: [ScreenEffectID: Task<Void, Never>] = [:]

    public init(
        document: ScreenDocument,
        initialState: ScreenState? = nil,
        reducer: ScreenReducer = ScreenReducer(),
        externalActionHandler: ExternalActionHandler = ExternalActionHandler(),
        effectExecutor: ScreenEffectExecutor = ScreenEffectExecutor()
    ) {
        self.document = document
        state = initialState ?? ScreenState(document: document)
        self.reducer = reducer
        self.externalActionHandler = externalActionHandler
        self.effectExecutor = effectExecutor
    }

    @discardableResult
    public func send(_ action: ScreenAction) -> [ScreenEffect] {
        var nextState = state
        let effects = reducer.reduce(&nextState, action)
        if nextState != state {
            state = nextState
        }
        for effect in effects {
            handle(effect)
        }
        return effects
    }

    public func cancelAllEffects() {
        let effectIDs = Set(runningEffects.keys).union(state.activeEffectIDs)
        for id in effectIDs {
            send(.cancelEffect(id: id))
        }
    }

    private func handle(_ effect: ScreenEffect) {
        switch effect {
        case let .forward(action):
            externalActionHandler.handle(action)
        case let .run(id, request):
            start(id: id, request: request)
        case let .cancel(id):
            runningEffects[id]?.cancel()
            runningEffects[id] = nil
        }
    }

    private func start(id: ScreenEffectID, request: ScreenEffectRequest) {
        runningEffects[id]?.cancel()
        let executor = effectExecutor
        runningEffects[id] = Task { @MainActor [weak self] in
            let result = await executor.run(request)
            guard !Task.isCancelled, let self else {
                return
            }
            runningEffects[id] = nil
            send(.effectCompleted(id: id, result: result))
        }
    }
}
