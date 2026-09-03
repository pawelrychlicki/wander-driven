# ADR 0002: Use an explicit registry with a focused attached macro

- Status: Accepted
- Date: 2026-09-03

## Context

The renderer receives component types as strings, so it needs a runtime lookup. Hand-writing every adapter is noisy, but implicit module-wide discovery would make registration order, duplicate behavior, and compile-time costs harder to explain. The portfolio should show useful macro work without hiding the system's composition.

## Decision

`@SDUIComponent("wire.type")` is an attached member macro. It generates the static component identifier and the `AnyComponentRegistration` adapter that decodes concrete `Properties` and invokes `makeView`. Application code still lists registrations explicitly in `AppComponentRegistry`.

The registry rejects duplicate component types deterministically. Type erasure is confined to `AnyComponentRegistration` because heterogeneous runtime lookup requires it.

## Consequences

### Positive

- Component declarations contain their wire identity next to their typed properties and view factory.
- The macro removes repetitive decoding and adapter boilerplate while keeping generated code small and inspectable.
- Explicit registration makes dependencies, duplicate failures, and test fixtures obvious.
- A future module can choose its own registry composition without global side effects.

### Trade-offs

- Adding a component requires one explicit registration line.
- The macro does not discover every annotated type automatically.
- Macro expansion tests and SwiftSyntax remain part of the package's toolchain surface.
