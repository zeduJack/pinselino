#!/usr/bin/env python3
"""Validate a paint-group profile and build combined runtime paths."""

from __future__ import annotations

import argparse
from pathlib import Path

from coloring_pipeline.grouping import build_paint_groups


def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("processed_directory", type=Path)
    parser.add_argument("profile", type=Path)
    parser.add_argument("output", type=Path)
    args = parser.parse_args()
    result = build_paint_groups(
        args.processed_directory,
        args.profile,
        args.output,
    )
    print(
        f"Prepared {result['templateId']} profile {result['profileId']}: "
        f"{len(result['paintGroups'])} paint groups -> {args.output}"
    )


if __name__ == "__main__":
    main()
