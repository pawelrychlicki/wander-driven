# ADR 0001: Keep the document immutable and normalize runtime state

- Status: Accepted
- Date: 2026-09-03

## Context

Server-driven content describes what should be rendered, while interaction state describes what a person has done. If those concerns share one mutable tree, a favorite tap can make the source document difficult to cache, compare, validate, or replay. It also couples a component's local interaction to the shape of the wire payload.

The app needs a small state model that can survive SwiftUI view reconstruction and remain easy to test without a running UI.

## Decision

`ScreenDocument` and its `ScreenNode` values are immutable `Codable`, `Equatable`, and `Sendable` data. `ScreenState` stores normalized runtime values in dictionaries keyed by stable `ComponentID`. `ScreenReducer` is the only place that changes state, and `ScreenStore` owns the reducer and effect lifecycle.

Actions carry stable IDs or document payloads; they never mutate a `ScreenNode`. Components receive only their own state projection through `ComponentContext`.

## Consequences

### Positive

- Documents can be cached, validated, compared, and re-rendered independently of user interaction.
- Reducer tests are synchronous and deterministic.
- State survives a view reconstruction as long as the host retains the route's `ScreenStore`.
- The same reducer contract can later be driven by remote documents or a different UI host.

### Trade-offs

- The renderer needs a lookup from a component ID to its current state.
- The demo uses a revision token to invalidate a cached rendered tree; a production app may prefer finer-grained observation to preserve scroll position during every update.
- State migration is a future concern if a new schema changes component identity. Stable IDs are therefore part of the document contract, not an implementation detail.
