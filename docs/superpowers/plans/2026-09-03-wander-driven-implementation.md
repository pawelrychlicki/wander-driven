# WanderDriven Implementation Plan

**Goal:** Build a public, production-minded iOS 26 portfolio application and reusable Server-Driven UI package demonstrating macros, native rendering, resilient decoding, unidirectional state management, UIKit interoperability, accessibility, and automated testing.

**Architecture:** `ServerDrivenKit` owns immutable documents, validation, registry-driven rendering, diagnostics, normalized runtime state, reducers, and effects. `ServerDrivenMacros` generates the adapter that connects strongly typed components to the heterogeneous registry. `WanderDriven` owns travel-specific components, local documents, navigation, favorites, and presentation.

**Toolchain:** Xcode 26.3, Swift 6.2.4, iOS 26, SwiftUI, UIKit, Observation, Swift Testing, SwiftSyntax macro tooling, XCUITest, XcodeGen, GitHub Actions.

**Working rules:** Implement each behavior test-first. Keep commits small and green. Do not use or reproduce employer code or non-public design details. Avoid third-party runtime dependencies; SwiftSyntax is permitted for the macro target, and XcodeGen is development tooling only.

---

## Task 1: Create the reproducible workspace skeleton

**Files:**

- Create: `project.yml`
- Create: `WanderDriven/App/WanderDrivenApp.swift`
- Create: `WanderDriven/App/RootView.swift`
- Create: `WanderDriven/Resources/Assets.xcassets/Contents.json`
- Create: `WanderDriven/Resources/Assets.xcassets/AccentColor.colorset/Contents.json`
- Create: `WanderDrivenUITests/WanderDrivenUITests.swift`
- Create: `Packages/ServerDriven/Package.swift`
- Create: `Packages/ServerDriven/Sources/ServerDrivenKit/ServerDrivenKit.swift`
- Create: `Packages/ServerDriven/Sources/ServerDrivenMacros/ServerDrivenMacros.swift`
- Create: `Packages/ServerDriven/Tests/ServerDrivenKitTests/SmokeTests.swift`
- Create: `Packages/ServerDriven/Tests/ServerDrivenMacrosTests/SmokeMacroTests.swift`
- Create: `.gitignore`

**Steps:**

1. Write a minimal Swift Testing smoke test that imports `ServerDrivenKit` and fails because the package product does not exist.
2. Define package products and targets for `ServerDrivenKit`, `ServerDrivenMacros`, and their tests. Add only the SwiftSyntax products required to build and test the macro.
3. Run `swift test --package-path Packages/ServerDriven` and confirm the smoke tests pass.
4. Define the iOS 26 application and UI-test targets in `project.yml`, referencing the local package.
5. Run `xcodegen generate` and inspect the generated schemes.
6. Build the application for an available iOS 26 simulator:

   ```bash
   xcodebuild -project WanderDriven.xcodeproj \
     -scheme WanderDriven \
     -destination 'platform=iOS Simulator,name=iPhone 17 Pro' \
     build
   ```

7. Commit with `chore: bootstrap WanderDriven workspace`.

## Task 2: Define document values and JSON fixtures

**Files:**

- Create: `Packages/ServerDriven/Sources/ServerDrivenKit/Document/ComponentID.swift`
- Create: `Packages/ServerDriven/Sources/ServerDrivenKit/Document/JSONValue.swift`
- Create: `Packages/ServerDriven/Sources/ServerDrivenKit/Document/ScreenDocument.swift`
- Create: `Packages/ServerDriven/Sources/ServerDrivenKit/Document/ScreenNode.swift`
- Create: `Packages/ServerDriven/Tests/ServerDrivenKitTests/DocumentDecodingTests.swift`
- Create: `Packages/ServerDriven/Tests/ServerDrivenKitTests/Fixtures/valid-discover.json`
- Create: `Packages/ServerDriven/Tests/ServerDrivenKitTests/Fixtures/invalid-root.json`

**Steps:**

1. Write failing decoding tests for a versioned document, stable node identifiers, primitive and registered component types, children, properties, and actions.
2. Introduce a small recursive, `Codable`, `Equatable`, `Sendable` `JSONValue` rather than `[String: Any]`.
3. Implement immutable `ScreenDocument` and `ScreenNode` value types with the smallest API needed by the tests.
4. Test malformed JSON and missing required root fields with structured errors rather than display strings.
5. Run the document tests and the entire package suite.
6. Commit with `feat: define server-driven document schema`.

## Task 3: Add structural validation

**Files:**

- Create: `Packages/ServerDriven/Sources/ServerDrivenKit/Validation/DocumentValidator.swift`
- Create: `Packages/ServerDriven/Sources/ServerDrivenKit/Validation/ValidationIssue.swift`
- Create: `Packages/ServerDriven/Tests/ServerDrivenKitTests/DocumentValidationTests.swift`

**Steps:**

1. Write failing tests for supported schema version, duplicate IDs, invalid container children, missing action fields, and valid nested documents.
2. Implement `DocumentValidator` as a deterministic value type that returns structured issues.
3. Make duplicate-ID diagnostics contain the offending `ComponentID` and a stable issue code.
4. Keep component-specific property validation out of this stage; it belongs to component factories.
5. Run focused and full package tests.
6. Commit with `feat: validate screen document structure`.

## Task 4: Implement the registry contract without macros

**Files:**

- Create: `Packages/ServerDriven/Sources/ServerDrivenKit/Components/ComponentDefinition.swift`
- Create: `Packages/ServerDriven/Sources/ServerDrivenKit/Components/AnyComponentRegistration.swift`
- Create: `Packages/ServerDriven/Sources/ServerDrivenKit/Components/ComponentRegistry.swift`
- Create: `Packages/ServerDriven/Sources/ServerDrivenKit/Components/ComponentRegistryBuilder.swift`
- Create: `Packages/ServerDriven/Sources/ServerDrivenKit/Rendering/ComponentContext.swift`
- Create: `Packages/ServerDriven/Tests/ServerDrivenKitTests/ComponentRegistryTests.swift`

**Steps:**

1. Write failing tests for successful registration, missing lookup, deterministic duplicate registration failure, and independent test registries.
2. Define the strongly typed `ComponentDefinition` contract and the narrow `ComponentContext`.
3. Implement type erasure only inside `AnyComponentRegistration`.
4. Implement the result builder so registrations compose declaratively while duplicates remain visible as errors.
5. Add a hand-written test component adapter. This establishes the exact boilerplate the macro must later generate.
6. Run tests and commit with `feat: add extensible component registry`.

## Task 5: Generate registrations with `@SDUIComponent`

**Files:**

- Modify: `Packages/ServerDriven/Package.swift`
- Create: `Packages/ServerDriven/Sources/ServerDrivenMacros/SDUIComponentMacro.swift`
- Create: `Packages/ServerDriven/Sources/ServerDrivenMacros/Diagnostics.swift`
- Create: `Packages/ServerDriven/Sources/ServerDrivenKit/Macros/SDUIComponent.swift`
- Create: `Packages/ServerDriven/Tests/ServerDrivenMacrosTests/SDUIComponentMacroTests.swift`
- Modify: `Packages/ServerDriven/Tests/ServerDrivenKitTests/ComponentRegistryTests.swift`

**Steps:**

1. Write failing macro expansion tests for a valid declaration and diagnostics for an empty identifier and unsupported attachment.
2. Implement only the attached macro roles needed to synthesize the identifier and type-erased registration adapter.
3. Ensure generated names are explicit in the macro declaration and expansion snapshots remain readable.
4. Replace the hand-written test adapter with `@SDUIComponent` and keep the same registry behavior tests green.
5. Run macro tests and the complete package suite.
6. Commit with `feat: generate component registration adapters`.

## Task 6: Add diagnostics and resilient component resolution

**Files:**

- Create: `Packages/ServerDriven/Sources/ServerDrivenKit/Diagnostics/RenderDiagnostic.swift`
- Create: `Packages/ServerDriven/Sources/ServerDrivenKit/Diagnostics/DiagnosticPolicy.swift`
- Create: `Packages/ServerDriven/Sources/ServerDrivenKit/Rendering/ResolvedComponent.swift`
- Create: `Packages/ServerDriven/Tests/ServerDrivenKitTests/ComponentResolutionTests.swift`

**Steps:**

1. Write failing tests for unknown component identifiers and malformed properties of known components.
2. Model successful, unsupported, and invalid-property resolution as explicit values.
3. Include component ID, component type, stable issue code, and safe debug context in diagnostics.
4. Define debug and release presentation policies without coupling structured diagnostics to localized UI text.
5. Confirm a failed node does not prevent successful siblings from resolving.
6. Run tests and commit with `feat: contain component resolution failures`.

## Task 7: Build primitive rendering and fallback views

**Files:**

- Create: `Packages/ServerDriven/Sources/ServerDrivenKit/Rendering/ScreenRenderer.swift`
- Create: `Packages/ServerDriven/Sources/ServerDrivenKit/Rendering/NodeRenderer.swift`
- Create: `Packages/ServerDriven/Sources/ServerDrivenKit/Rendering/UnsupportedComponentView.swift`
- Create: `Packages/ServerDriven/Sources/ServerDrivenKit/Rendering/InvalidComponentView.swift`
- Create: `Packages/ServerDriven/Sources/ServerDrivenKit/Primitives/TextComponent.swift`
- Create: `Packages/ServerDriven/Sources/ServerDrivenKit/Primitives/ImageComponent.swift`
- Create: `Packages/ServerDriven/Sources/ServerDrivenKit/Primitives/ButtonComponent.swift`
- Create: `Packages/ServerDriven/Sources/ServerDrivenKit/Primitives/DividerComponent.swift`
- Create: `Packages/ServerDriven/Sources/ServerDrivenKit/Primitives/ContainerComponents.swift`
- Create: `Packages/ServerDriven/Tests/ServerDrivenKitTests/PrimitiveComponentTests.swift`

**Steps:**

1. Write failing tests for primitive property decoding and action emission.
2. Implement vertical, horizontal, and scroll containers with stable identity and adaptive layout.
3. Implement semantic text styles, system colors, minimum 44-point button targets, Dynamic Type behavior, and meaningful accessibility values.
4. Apply type erasure only where runtime component selection requires it; do not propagate `AnyView` through models or state.
5. Add previews covering light, dark, large Dynamic Type, and diagnostic states.
6. Build the package and app, run tests, and commit with `feat: render primitives and diagnostic fallbacks`.

## Task 8: Implement normalized runtime state and reducer

**Files:**

- Create: `Packages/ServerDriven/Sources/ServerDrivenKit/State/ComponentState.swift`
- Create: `Packages/ServerDriven/Sources/ServerDrivenKit/State/ScreenState.swift`
- Create: `Packages/ServerDriven/Sources/ServerDrivenKit/State/ScreenAction.swift`
- Create: `Packages/ServerDriven/Sources/ServerDrivenKit/State/ScreenReducer.swift`
- Create: `Packages/ServerDriven/Sources/ServerDrivenKit/State/ScreenEffect.swift`
- Create: `Packages/ServerDriven/Sources/ServerDrivenKit/State/ScreenStore.swift`
- Create: `Packages/ServerDriven/Sources/ServerDrivenKit/Actions/ExternalActionHandler.swift`
- Create: `Packages/ServerDriven/Tests/ServerDrivenKitTests/ScreenReducerTests.swift`
- Create: `Packages/ServerDriven/Tests/ServerDrivenKitTests/ScreenStoreTests.swift`

**Steps:**

1. Write failing reducer tests for favorite toggling, alert presentation, unknown actions, and unchanged immutable documents.
2. Implement `ScreenReducer` as a synchronous deterministic value type returning a small list of effects.
3. Write failing store tests for effect results, cancellation, and external-action forwarding using controlled dependencies.
4. Implement an `@MainActor`, `@Observable` `ScreenStore`; keep effect work outside the reducer and return results as actions.
5. Test that state is keyed by `ComponentID` and survives view reconstruction for the same document identity.
6. Run concurrency checks under Swift 6 language mode and resolve isolation or `Sendable` warnings rather than suppressing them.
7. Commit with `feat: add unidirectional screen runtime`.

## Task 9: Add the bundled document source and application composition

**Files:**

- Create: `Packages/ServerDriven/Sources/ServerDrivenKit/Source/ScreenDocumentSource.swift`
- Create: `Packages/ServerDriven/Sources/ServerDrivenKit/Source/BundleScreenDocumentSource.swift`
- Create: `Packages/ServerDriven/Tests/ServerDrivenKitTests/BundleScreenDocumentSourceTests.swift`
- Create: `WanderDriven/App/AppModel.swift`
- Create: `WanderDriven/App/AppRoute.swift`
- Create: `WanderDriven/Features/ScenarioPicker/ScenarioPickerView.swift`
- Create: `WanderDriven/Features/ScreenHost/ServerDrivenScreen.swift`
- Modify: `WanderDriven/App/RootView.swift`

**Steps:**

1. Write failing source tests for successful bundled loading, missing resource, and malformed resource.
2. Implement the injected source protocol and bundled source only; do not add networking.
3. Compose decoder, validator, registry, reducer, and store at the app boundary.
4. Use `NavigationStack` with typed routes owned by the app.
5. Use a compact scenario picker appropriate for three developer-facing demonstrations; do not create unnecessary tabs.
6. Build, run tests, and commit with `feat: compose local server-driven scenarios`.

## Task 10: Implement travel components and UIKit interoperability

**Files:**

- Create: `WanderDriven/Components/DestinationCard/DestinationCard.swift`
- Create: `WanderDriven/Components/DestinationCard/DestinationCardView.swift`
- Create: `WanderDriven/Components/Badge/Badge.swift`
- Create: `WanderDriven/Components/Badge/BadgeView.swift`
- Create: `WanderDriven/Components/UIKitMapPreview/UIKitMapPreview.swift`
- Create: `WanderDriven/Components/UIKitMapPreview/UIKitMapPreviewRepresentable.swift`
- Create: `WanderDriven/Components/AppComponentRegistry.swift`
- Create: `WanderDrivenTests/DestinationCardTests.swift`
- Create: `WanderDrivenTests/UIKitMapPreviewTests.swift`
- Modify: `project.yml`

**Steps:**

1. Add the application unit-test target and write failing property-decoding and action tests for the travel components.
2. Declare each registered component with `@SDUIComponent` and add it explicitly to `AppComponentRegistry`.
3. Implement `DestinationCard` with adaptive layout, semantic typography, dark mode, a 44-point favorite action, and VoiceOver state.
4. Implement `Badge` without conveying meaning through color alone.
5. Implement a small UIKit map-preview or legacy-card view through `UIViewRepresentable`, with correct make/update lifecycle and no private global state.
6. Test that updates reach the UIKit view and actions return through `ComponentContext`.
7. Build, run all unit tests, and commit with `feat: add travel components and UIKit bridge`.

## Task 11: Author the three travel documents and visual experience

**Files:**

- Create: `WanderDriven/Resources/Documents/discover.json`
- Create: `WanderDriven/Resources/Documents/destination-lisbon.json`
- Create: `WanderDriven/Resources/Documents/diagnostics-lab.json`
- Add: `WanderDriven/Resources/Assets.xcassets/<travel image sets>`
- Create: `WanderDriven/Features/Diagnostics/DiagnosticsOverlay.swift`
- Modify: `WanderDriven/Features/ScreenHost/ServerDrivenScreen.swift`
- Create: `WanderDrivenTests/DocumentFixtureTests.swift`

**Steps:**

1. Write tests that decode and validate Discover and Destination Details and assert the intended issue set for Diagnostics Lab.
2. Author local JSON fixtures with stable IDs and independently designed schema values.
3. Use properly licensed original or generated travel imagery and document its provenance. Do not hotlink remote images.
4. Apply Liquid Glass only to navigation and interactive chrome after layout modifiers; keep content surfaces legible in light and dark mode.
5. Use current APIs such as `foregroundStyle`, `clipShape(.rect(...))`, modern alerts, and value-driven animation.
6. Verify layouts on compact and large iPhone simulators, landscape, accessibility Dynamic Type sizes, Reduce Motion, and Increase Contrast.
7. Commit with `feat: add WanderDriven demonstration scenarios`.

## Task 12: Add end-to-end UI tests

**Files:**

- Modify: `WanderDrivenUITests/WanderDrivenUITests.swift`
- Create: `WanderDriven/App/LaunchConfiguration.swift`

**Steps:**

1. Write a failing UI test that launches a deterministic scenario and confirms Discover content renders.
2. Add launch arguments for selecting fixtures without changing production behavior.
3. Test navigation to Destination Details and favorite state after view reconstruction.
4. Test Diagnostics Lab and verify valid sibling content remains visible beside diagnostic fallback content.
5. Use accessibility identifiers only where semantic labels are insufficient for deterministic automation.
6. Run the UI suite on the chosen iOS 26 simulator twice to expose ordering or state leakage.
7. Commit with `test: cover WanderDriven user journeys`.

## Task 13: Add formatting, linting, and continuous integration

**Files:**

- Create: `.swift-format`
- Create: `.swiftlint.yml`
- Create: `.github/workflows/ci.yml`
- Create: `scripts/verify.sh`
- Modify: `project.yml` if CI-specific scheme settings are required

**Steps:**

1. Add a single verification script that checks formatting, lints, runs package tests, builds the app, and runs the required UI tests.
2. Configure rules narrowly; do not suppress concurrency, force-cast, or force-unwrap problems globally.
3. Add separate GitHub Actions jobs for fast package/macro tests and application/UI verification.
4. Pin the stable Xcode version compatible with Xcode 26.3 rather than relying silently on runner defaults.
5. Run `scripts/verify.sh` locally from a clean working tree.
6. Commit with `ci: verify package and application`.

## Task 14: Write the portfolio case study

**Files:**

- Create: `README.md`
- Create: `docs/architecture.md`
- Create: `docs/decisions/0001-immutable-document-and-runtime-state.md`
- Create: `docs/decisions/0002-explicit-macro-backed-registry.md`
- Add: `docs/media/wander-driven-demo.gif`
- Add: `docs/media/discover.png`
- Add: `docs/media/diagnostics.png`
- Add: `LICENSE`

**Steps:**

1. Write the English README around the reviewer journey: problem, result, preview, architecture, macro example, failure handling, tests, and running instructions.
2. Add a concise data-flow diagram and sample JSON that match the implemented API exactly.
3. Explain why documents are immutable, state is normalized, registration is explicit, and macro use is intentionally limited.
4. Record non-goals and trade-offs, including local-only documents and iOS 26 minimum deployment.
5. Add a clear statement that the work is independently designed and contains no proprietary employer material.
6. Capture screenshots in light, dark, and diagnostic states after final UI verification.
7. Choose a permissive license only after confirming every included asset is compatible with it.
8. Commit with `docs: publish WanderDriven case study`.

## Task 15: Final verification and GitHub readiness

**Files:**

- Modify only files required by issues found during verification.

**Steps:**

1. Clone or copy the repository into a clean temporary directory and regenerate the project with XcodeGen.
2. Run `scripts/verify.sh` without relying on untracked local files.
3. Inspect all warnings and fail the handoff on new Swift concurrency, macro, or build warnings.
4. Manually verify Discover, Destination Details, and Diagnostics Lab on small and large iPhone simulators.
5. Verify VoiceOver reading order, accessibility labels, Dynamic Type reflow, dark mode, Reduce Motion, and Increase Contrast.
6. Check the README commands from the clean checkout.
7. Scan the repository for secrets, absolute local paths, employer code, internal identifiers, and accidental generated artifacts.
8. Review the final diff and repository history, then commit any verification fixes as `fix: address final verification findings`.

## Definition of Done

- The generated project builds with Xcode 26.3 and Swift 6.2.4.
- Package, macro, application, and required UI tests pass.
- CI reproduces local verification from a clean checkout.
- Three local scenarios demonstrate normal interaction and resilient failure handling.
- Runtime state is separate from the immutable document and flows through reducer-driven actions and effects.
- App-owned navigation remains outside `ServerDrivenKit`.
- `@SDUIComponent` removes adapter boilerplate while registry composition stays explicit.
- The primary UI is accessible, adaptive, and uses iOS 26 visual APIs appropriately.
- README and media make the repository credible as an international senior iOS portfolio piece.
- No confidential or copied employer material is present.
