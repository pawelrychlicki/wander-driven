# WanderDriven Design Specification

## 1. Purpose

WanderDriven is a public portfolio project demonstrating senior-level iOS engineering through a small, production-minded Server-Driven UI system. The project will show how to decode, validate, render, interact with, and test dynamic native interfaces while keeping the implementation understandable enough for a prospective client to review.

The project is not a reproduction of Allegro MBox. It will use an independently designed schema, API, component model, and runtime. Public descriptions of MBox may be referenced only as general professional context; no proprietary code, internal documentation, non-public behavior, or confidential implementation details may be used.

## 2. Audience and Success Criteria

The primary audience is international product companies, technical founders, CTOs, and mobile engineering leads looking for short-term senior iOS support.

The project succeeds when a reviewer can establish, within approximately ten minutes, that the author can:

- design a modular Swift framework with a small public API;
- work fluently with modern Swift, SwiftUI, and UIKit interoperability;
- use macros to remove meaningful boilerplate without hiding runtime behavior;
- model unidirectional state and action flow;
- handle malformed or unsupported server input safely;
- write deterministic tests for framework behavior and generated code;
- explain architectural decisions and trade-offs clearly.

## 3. Scope

### Included in version 1

- An iOS 26+ SwiftUI demonstration application named `WanderDriven`.
- A reusable Swift package module named `ServerDrivenKit`.
- A macro module named `ServerDrivenMacros`.
- Local JSON documents representing travel discovery and destination detail screens.
- Strongly typed layout primitives and actions.
- An extensible component registry.
- The attached `@SDUIComponent` macro.
- Immutable screen documents and normalized runtime state.
- A reducer, effects, and an external application action boundary.
- Graceful handling of invalid documents, components, properties, and actions.
- Swift Testing coverage, macro expansion tests, and a small UI test suite.
- A GitHub Actions workflow.
- An English README written as a concise technical case study.

### Excluded from version 1

- A backend service or remote JSON loading.
- Authentication, payments, booking, or production travel data.
- A visual schema editor or content management system.
- Persistent favorites or database storage.
- Network cache, telemetry, analytics, or A/B testing.
- A complete design system.
- Automatic discovery of every annotated component in a module.
- Compatibility with iOS versions earlier than iOS 26.
- Third-party state-management or architecture frameworks.

## 4. Repository and Module Structure

The repository will contain one Xcode project and one local Swift package:

```text
WanderDriven/
├── App/
│   ├── WanderDrivenApp.swift
│   ├── Features/
│   ├── Components/
│   ├── Resources/Documents/
│   └── Resources/Assets.xcassets/
├── Packages/ServerDriven/
│   ├── Package.swift
│   ├── Sources/ServerDrivenKit/
│   ├── Sources/ServerDrivenMacros/
│   ├── Tests/ServerDrivenKitTests/
│   └── Tests/ServerDrivenMacrosTests/
├── WanderDrivenUITests/
├── docs/
└── README.md
```

The package is split by responsibility rather than by every individual type. Files should remain focused, but version 1 will avoid premature creation of many small library products.

## 5. Demonstration Experience

The application contains a scenario picker and three demonstrations:

1. **Discover** renders a valid travel discovery document with a hero, promotional message, destination cards, badges, and actions.
2. **Destination Details** demonstrates navigation, favorite state, an alert, a horizontal section, and UIKit interoperability.
3. **Diagnostics Lab** intentionally includes an unknown component, malformed component properties, and an unsupported action to demonstrate local recovery.

The interface uses current iOS 26 APIs. Liquid Glass is limited to appropriate navigation and interactive controls. Rendered content uses native SwiftUI views, supports Dynamic Type, and exposes meaningful accessibility labels and traits. A UIKit-backed component demonstrates interoperability without making UIKit the core rendering mechanism.

## 6. Document Model and Schema

`ScreenDocument` is an immutable, `Sendable` representation of a decoded screen definition. Each node has a stable `ComponentID`, a component type, properties payload, optional children where permitted, and optional actions.

Layout primitives are strongly typed and built into the framework:

- `vertical`
- `horizontal`
- `scroll`

Initial content components are:

- `text`
- `image`
- `button`
- `destinationCard`
- `badge`
- `divider`

Supported application behaviors are represented by strongly typed actions:

- `navigate`
- `showAlert`
- `toggleFavorite`

The schema has an explicit version. A document using an unsupported schema version fails at the document boundary with a controlled error. Unknown component and action identifiers within an otherwise supported document do not crash the application.

Component-specific properties are never represented as `[String: Any]`. Their raw JSON payload is retained in a decodable representation until the selected component registration decodes it into its concrete `Properties` type.

## 7. Decoding and Validation

The data flow is:

```text
Local JSON
    -> DocumentDecoder
    -> Validated ScreenDocument
    -> ComponentRegistry
    -> SwiftUI Renderer
    -> ScreenAction
    -> ScreenStore / host application
```

`DocumentDecoder` handles syntax and structural decoding. A separate validation step checks schema version, stable and unique component identifiers, container constraints, and required action fields. Separating the two stages makes failures specific and testable.

Local files are accessed through an injected `ScreenDocumentSource` protocol. Version 1 provides only `BundleScreenDocumentSource`. A future remote source can be added without changing decoding, rendering, or state management.

## 8. Component Registry and Macro

The registry maps a component identifier to a type-erased factory. Type erasure exists only at this heterogeneous runtime boundary. Concrete component properties and rendering implementations remain strongly typed.

A component is declared in the following style:

```swift
@SDUIComponent("destinationCard")
struct DestinationCard: ComponentDefinition {
    struct Properties: Decodable, Sendable {
        let id: String
        let title: String
        let imageName: String
    }

    static func makeView(
        properties: Properties,
        context: ComponentContext
    ) -> some View {
        DestinationCardView(
            destination: properties,
            send: context.send
        )
    }
}
```

`@SDUIComponent` generates the repetitive adapter required by the registry:

- the component identifier;
- a type-erased registration value;
- decoding of the concrete `Properties` type;
- conversion of property decoding failures into framework diagnostics;
- required generated conformance or members.

The macro must emit compile-time diagnostics for an empty identifier, an unsupported declaration kind, or a declaration that cannot meet the generated API contract.

Registration remains explicit and deterministic:

```swift
let registry = ComponentRegistry {
    DestinationCard.registration
    Badge.registration
}
```

`ComponentRegistry` uses a result builder only to improve composition. The project will not add a second freestanding registry macro in version 1 and will not attempt implicit module-wide component discovery.

## 9. Rendering

The renderer recursively processes validated nodes. Layout primitives are rendered directly by `ServerDrivenKit`; content nodes are resolved through `ComponentRegistry`.

The framework passes a narrow `ComponentContext` containing only the component identifier, current component state required for rendering, and a `send` closure. Components do not receive the complete store or an unrestricted environment object.

Because the view type is selected at runtime, the registry uses justified view type erasure at its boundary. Type erasure must not leak into document models, reducer state, or public action types. Dynamic collections use stable `ComponentID` values rather than indices.

## 10. State, Actions, and Effects

The runtime uses unidirectional data flow inspired by Redux, without a third-party Redux dependency.

The decoded `ScreenDocument` is immutable and never mutated to represent user interaction. Runtime values are normalized separately:

```swift
struct ScreenState: Equatable, Sendable {
    var componentStates: [ComponentID: ComponentState]
    var presentedAlert: AlertState?
}
```

The core elements are:

- `ScreenState`: normalized runtime state keyed by stable component identifiers;
- `ScreenAction`: strongly typed events from components, effects, or the host;
- `ScreenReducer`: a synchronous, deterministic function that mutates state and returns effects;
- `ScreenEffect`: descriptions of asynchronous work;
- `ScreenStore`: an `@MainActor`, `@Observable` owner that publishes state, invokes the reducer, runs effects, and supports cancellation;
- `ExternalActionHandler`: a host-provided boundary for navigation and other application-owned behaviors.

Internal actions such as toggling favorite state or presenting a document-defined alert are reduced by the screen runtime. External actions such as navigating to a destination or opening a host feature are emitted to the application. `ServerDrivenKit` does not own the host application's navigation stack.

Effects send their results back as actions. Reducer tests therefore remain synchronous and deterministic, while effect executors can be tested with controlled dependencies. Version 1 will include only effects required by the local demonstrations; it will not build a general-purpose effects framework.

## 11. Error Handling and Diagnostics

Failures are contained at the narrowest safe boundary:

- Invalid JSON syntax or an invalid document root produces a full-screen document error.
- An unsupported schema version produces a controlled document error.
- An unknown component produces `UnsupportedComponentView`; sibling nodes continue rendering.
- Invalid properties for a known component produce a local component fallback.
- An unknown action produces a diagnostic and no crash.
- Duplicate identifiers or structurally invalid containers fail validation before rendering.

Diagnostics have debug and release presentation policies. Debug builds show actionable detail including component identifiers and decoding context. Release presentation is neutral and does not expose internal implementation detail. Tests assert structured diagnostic values rather than localized display strings.

## 12. Dependencies and Platform Choices

- Minimum deployment: iOS 26.
- Language mode: the latest stable Swift language mode available in the selected stable Xcode release at implementation time.
- UI: SwiftUI, with one purposeful UIKit integration.
- Observation: `@Observable` and related current APIs.
- Concurrency: structured concurrency with explicit actor isolation and `Sendable` models.
- Tests: Swift Testing for package behavior; XCUITest for selected end-to-end flows.
- Macros: SwiftSyntax-based macro target as required by Swift macro tooling.
- External runtime libraries: none unless implementation uncovers a requirement that cannot be met reasonably with platform APIs.

Latest stable API choices must be verified against the installed stable Xcode toolchain before implementation. Beta-only APIs are out of scope.

## 13. Testing Strategy

### Unit and integration tests

- valid document decoding;
- syntax and structural decoding failures;
- schema version validation;
- duplicate component identifier validation;
- registry lookup and duplicate registration behavior;
- concrete component property decoding;
- unknown component and action recovery;
- pure reducer state transitions;
- effect result propagation and cancellation;
- preservation of normalized state across SwiftUI re-rendering;
- separation of external actions from framework state;
- component accessibility semantics where they can be asserted reliably.

### Macro tests

- expected expansion for a valid component;
- generated identifier and registration adapter;
- invalid attachment target diagnostic;
- empty identifier diagnostic;
- missing or invalid component contract diagnostic.

### UI tests

- launch and render Discover;
- navigate to Destination Details;
- toggle a favorite and observe state preservation;
- open Diagnostics Lab and confirm sibling content survives invalid nodes.

Tests must not depend on network access, wall-clock time, or unordered global state.

## 14. Continuous Integration

GitHub Actions will build the application and run package and UI tests using a pinned stable Xcode version compatible with iOS 26. The workflow will separate fast package tests from the application build and UI test job so failures are easy to diagnose.

Macro expansion tests and all package tests run on every pull request. If UI test execution proves too slow or unreliable for free hosted runners, the initial workflow may run the small UI suite only on the main branch, with that trade-off documented.

## 15. README and Portfolio Presentation

The English README is part of the deliverable, not an afterthought. It will include:

- a concise problem statement;
- a short GIF or video preview and selected screenshots;
- the system architecture and data-flow diagram;
- a sample JSON document;
- a component declaration using `@SDUIComponent`;
- an explanation of immutable documents and normalized runtime state;
- failure-containment examples from Diagnostics Lab;
- build and test instructions;
- explicit design trade-offs and non-goals;
- a note that the project is independently designed and contains no proprietary employer code.

The profile repository should eventually be pinned on GitHub alongside a short profile README describing the author's iOS specialization and contact path. That profile work is separate from the version 1 implementation.

## 16. Milestones

At approximately five hours per week, the expected implementation window is four to six weeks:

1. Project skeleton, schema, decoding, and validation.
2. Registry, macro, and macro expansion tests.
3. Renderer, primitive components, and error fallbacks.
4. Store, reducer, actions, effects, and host integration.
5. Demo scenarios, UIKit interoperability, accessibility, and UI tests.
6. CI, README case study, screenshots, and final polish.

Milestones are outcome-based; implementation may combine adjacent milestones when that reduces overhead without weakening verification.

## 17. Acceptance Criteria

Version 1 is complete when:

- the project builds with the selected stable Xcode toolchain;
- all automated package, macro, and required UI tests pass;
- the three bundled JSON scenarios render as designed;
- state changes flow through the reducer and survive view re-rendering;
- external navigation remains owned by the demo application;
- invalid nodes demonstrate local recovery without crashing valid siblings;
- the macro removes registration boilerplate and has readable expansion tests;
- the app is usable with large Dynamic Type and VoiceOver for its primary flows;
- CI passes from a clean checkout;
- the README enables a reviewer to understand and run the project without additional guidance;
- the repository contains no confidential, proprietary, or copied employer material.
