# WanderDriven architecture

This note is the short technical companion to the README. It focuses on boundaries and invariants rather than describing every file.

## Runtime pipeline

1. `ScreenDocumentSource` loads a named resource. The shipped implementation is `BundleScreenDocumentSource`; networking is intentionally outside version 1.
2. `JSONDecoder` creates an immutable `ScreenDocument` made of `ScreenNode` values and recursive `JSONValue` properties.
3. `DocumentValidator` checks schema support, stable and unique IDs, container rules, and fields required by known action types.
4. `ScreenRenderer` recursively renders layout primitives and asks `ComponentRegistry` to resolve content nodes.
5. The registry decodes concrete component properties at the last responsible moment and turns failures into `ResolvedComponent.invalidProperties`.
6. A component sends a `DocumentAction` through its narrow `ComponentContext`. The host wraps that event in `ScreenAction.document` and sends it to `ScreenStore`.
7. `ScreenReducer` mutates only `ScreenState` and returns `ScreenEffect` values. Effects can forward a host action, start an injected async operation, or cancel an operation.
8. `ScreenStore` executes effects on the main actor, drops late results after cancellation, and publishes the updated state back to SwiftUI.

## Boundaries and invariants

### Immutable content

`ScreenDocument` is `let`-backed and `Sendable`. A favorite tap never rewrites JSON or replaces a node. This means the same document can be rendered again, inspected in tests, or cached independently from interaction state.

### Normalized state

`ScreenState.componentStates` is keyed by stable `ComponentID`. The reducer can update a card without traversing or mutating the document. The app's cached `ScreenStore` keeps that state when SwiftUI reconstructs the view hierarchy.

### Narrow component context

Components receive their own ID, declared actions, their current `ComponentState`, and a send closure. They cannot reach into the complete store or mutate navigation directly. This keeps component code portable and makes action flow visible in tests.

### Type erasure at one edge

The wire type is dynamic, so `AnyComponentRegistration` and `AnyView` are necessary at the registry/renderer boundary. They do not leak into documents, action payloads, reducer state, or component properties. Concrete components remain strongly typed.

### Host-owned navigation

`ServerDrivenKit` emits `ExternalAction.navigate`. `WanderDriven.AppModel` maps that action to a typed `NavigationStack` route. The reusable package therefore has no dependency on the app's route enum or navigation storage.

### Diagnostics are data first

`RenderDiagnostic` has a stable code, component ID, component type, and detail. The renderer chooses a debug or release presentation policy, while tests assert the structured value rather than a localized sentence.

## Concurrency model

- Documents, actions, effects, and diagnostics are `Sendable` value types.
- UI factories and `ScreenStore` are `@MainActor`.
- `ScreenEffectExecutor` is an injected async dependency. A running task is associated with a `ScreenEffectID`; cancellation removes the ID and late results are ignored.
- The running-task dictionary is deliberately `@ObservationIgnored`. SwiftUI observes `ScreenStore.state` directly; unchanged reducer output is not reassigned.

## Route-scoped loading and observation

The app caches a load result per route in an observed collection. A failure on one route cannot replace another route's content or error. The rendered screen reads its store's state directly, so a favorite update does not change the identity of the whole screen or reset its scroll position.

For larger feeds, per-component observable projections could reduce redraw fan-out further; the immutable document and normalized state boundaries would remain unchanged.

## Testing map

| Concern | Test location |
| --- | --- |
| Codable document shape and malformed roots | `Packages/ServerDriven/Tests/ServerDrivenKitTests/DocumentDecodingTests.swift` |
| Structural validation | `DocumentValidationTests.swift` |
| Registry and macro expansion | `ComponentRegistryTests.swift`, `ServerDrivenMacrosTests` |
| Local fallback resolution | `ComponentResolutionTests.swift` |
| Reducer transitions and external actions | `ScreenReducerTests.swift` |
| Effect result and cancellation lifecycle | `ScreenStoreTests.swift` |
| Travel component properties and UIKit updates | `WanderDrivenTests` |
| Bundled scenario contracts | `WanderDrivenTests/DocumentFixtureTests.swift` |
| Route-scoped loading and retry | `WanderDrivenTests/AppModelTests.swift` |
| End-to-end navigation, alert, favorite persistence, and diagnostics | `WanderDrivenUITests/WanderDrivenUITests.swift` |

All tests use local data and deterministic dependencies. No test needs a network connection or wall-clock timing.
