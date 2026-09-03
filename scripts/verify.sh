#!/usr/bin/env bash

set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$repo_root"

echo "==> SwiftFormat"
swift_sources=(
  WanderDriven
  WanderDrivenTests
  WanderDrivenUITests
  Packages/ServerDriven/Sources
  Packages/ServerDriven/Tests
)
swiftformat --lint --swift-version 6 "${swift_sources[@]}"

echo "==> SwiftLint"
swiftlint lint --no-cache --strict --config .swiftlint.yml

echo "==> ServerDriven package tests"
swift test --package-path Packages/ServerDriven

echo "==> Generate Xcode project"
xcodegen generate

derived_data="${TMPDIR:-/tmp}/WanderDrivenDerivedData"
echo "==> Build app and test bundles"
xcodebuild \
  -project WanderDriven.xcodeproj \
  -scheme WanderDriven \
  -destination "generic/platform=iOS Simulator" \
  -derivedDataPath "$derived_data" \
  CODE_SIGNING_ALLOWED=NO \
  build-for-testing

if [[ "${RUN_UI_TESTS:-0}" == "1" ]]; then
  echo "==> UI tests"
  xcodebuild \
    -project WanderDriven.xcodeproj \
    -scheme WanderDriven \
    -destination "${UI_TEST_DESTINATION:-platform=iOS Simulator,name=iPhone 17 Pro}" \
    -derivedDataPath "$derived_data" \
    CODE_SIGNING_ALLOWED=NO \
    -only-testing:WanderDrivenUITests \
    test \
    -quiet
fi

echo "Verification complete."
