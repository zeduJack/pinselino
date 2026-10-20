#!/usr/bin/env bash

set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

"$repo_root/scripts/verify-coloring-pipeline.sh"

cd "$repo_root/app"

echo "==> Resolve Flutter dependencies"
flutter pub get

echo "==> Check Dart formatting"
dart format --output=none --set-exit-if-changed lib test

echo "==> Run static analysis"
flutter analyze

echo "==> Run all unit, widget, and golden tests"
flutter test

echo "==> Build Android debug APK"
flutter build apk --debug

echo "==> Pinselino verification passed"
