#!/usr/bin/env bash

set -euo pipefail

if [[ $# -lt 1 || $# -gt 2 ]]; then
  echo "Usage: $0 <flutter-device-id> [--debug|--profile]" >&2
  exit 64
fi

device_id="$1"
build_mode="${2:---profile}"
if [[ "$build_mode" != "--debug" && "$build_mode" != "--profile" ]]; then
  echo "Build mode must be --debug or --profile." >&2
  exit 64
fi
repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$repo_root/app"

flutter drive \
  --driver test_driver/integration_test.dart \
  --target integration_test/coloring_performance_test.dart \
  --device-id "$device_id" \
  "$build_mode"
