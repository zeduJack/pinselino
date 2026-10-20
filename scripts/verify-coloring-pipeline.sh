#!/usr/bin/env bash

set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
tool_root="$repo_root/tools/coloring_pipeline"
venv="$tool_root/.venv"

if [[ ! -x "$venv/bin/python" ]]; then
  echo "==> Create coloring-pipeline Python environment"
  python3 -m venv "$venv"
fi

echo "==> Resolve coloring-pipeline dependencies"
"$venv/bin/python" -m pip install --disable-pip-version-check --quiet \
  -r "$tool_root/requirements.txt"

echo "==> Compile coloring-pipeline Python sources"
PYTHONPATH="$tool_root" "$venv/bin/python" -m compileall -q \
  "$tool_root/coloring_pipeline" \
  "$tool_root/prepare_coloring_page.py" \
  "$tool_root/prepare_paint_groups.py" \
  "$tool_root/tests"

echo "==> Run coloring-pipeline unit tests"
PYTHONPATH="$tool_root" "$venv/bin/python" -m unittest discover \
  -s "$tool_root/tests" \
  -p 'test_*.py' \
  -v

echo "==> Coloring-pipeline verification passed"
