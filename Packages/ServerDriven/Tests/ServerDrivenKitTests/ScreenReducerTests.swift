@testable import ServerDrivenKit
import Testing

struct ScreenReducerTests {
    @Test("toggles favorite state by destination component ID")
    func togglesFavoriteState() {
        let document = makeDocument()
        var state = ScreenState(document: document)
        let reducer = ScreenReducer()
        let action = DocumentAction(
            type: "toggleFavorite",
            payload: .object(["destinationID": .string("lisbon")])
        )

        let effects = reducer.reduce(
            &state,
            .document(componentID: "favorite-button", action: action)
        )

        #expect(state.componentStates["lisbon"]?.isFavorite == true)
        #expect(effects.isEmpty)

        _ = reducer.reduce(
            &state,
            .document(componentID: "favorite-button", action: action)
        )

        #expect(state.componentStates["lisbon"]?.isFavorite == false)
    }

    @Test("presents a structured alert from a document action")
    func presentsAlert() {
        let document = makeDocument()
        var state = ScreenState(document: document)
        let reducer = ScreenReducer()
        let action = DocumentAction(
            type: "showAlert",
            payload: .object([
                "title": .string("Offline"),
                "message": .string("Saved locally for your next trip."),
            ])
        )

        let effects = reducer.reduce(
            &state,
            .document(componentID: "root", action: action)
        )

        #expect(
            state.presentedAlert == AlertState(
                title: "Offline",
                message: "Saved locally for your next trip."
            )
        )
        #expect(effects.isEmpty)
    }

    @Test("ignores unknown document actions without changing state")
    func ignoresUnknownAction() {
        let document = makeDocument()
        var state = ScreenState(document: document)
        let initialState = state
        let reducer = ScreenReducer()

        let effects = reducer.reduce(
            &state,
            .document(
                componentID: "root",
                action: DocumentAction(
                    type: "futureAction",
                    payload: .object(["value": .string("kept for later")])
                )
            )
        )

        #expect(state == initialState)
        #expect(effects.isEmpty)
    }

    @Test("records effect lifecycle without mutating the document")
    func recordsEffectLifecycle() {
        let document = makeDocument()
        var state = ScreenState(document: document)
        let initialDocument = document
        let reducer = ScreenReducer()
        let request = ScreenEffectRequest(id: "refresh", kind: .refresh)

        let startEffects = reducer.reduce(&state, .startEffect(request))

        #expect(state.activeEffectIDs == ["refresh"])
        #expect(startEffects == [.run(id: "refresh", request: request)])

        let result = ScreenEffectResult.success(.completed)
        let completionEffects = reducer.reduce(
            &state,
            .effectCompleted(id: "refresh", result: result)
        )

        #expect(state.activeEffectIDs.isEmpty)
        #expect(state.lastEffectResult == result)
        #expect(completionEffects.isEmpty)
        #expect(document == initialDocument)
    }

    private func makeDocument() -> ScreenDocument {
        ScreenDocument(
            schemaVersion: 1,
            root: ScreenNode(
                id: "root",
                type: "vertical",
                children: [
                    ScreenNode(id: "lisbon", type: "destination.card"),
                    ScreenNode(id: "favorite-button", type: "button"),
                ]
            )
        )
    }
}
