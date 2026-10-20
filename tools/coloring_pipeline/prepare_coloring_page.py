#!/usr/bin/env python3
"""Command-line entry point for coloring-page preprocessing."""

from __future__ import annotations

import argparse
from pathlib import Path

from coloring_pipeline import ProcessingConfig, process_coloring_page


def _parser() -> argparse.ArgumentParser:
    parser = argparse.ArgumentParser(
        description="Prepare line art for Pinselino's bounded painting runtime."
    )
    parser.add_argument("source", type=Path)
    parser.add_argument("output_directory", type=Path)
    parser.add_argument("--id", required=True, dest="template_id")
    parser.add_argument("--title", required=True)
    parser.add_argument("--category", required=True)
    parser.add_argument("--line-threshold", type=int, default=210)
    parser.add_argument("--close-gap-pixels", type=int, default=1)
    parser.add_argument("--minimum-region-pixels", type=int, default=400)
    parser.add_argument("--minimum-touch-dimension", type=int, default=24)
    return parser


def main() -> None:
    args = _parser().parse_args()
    result = process_coloring_page(
        args.source,
        args.output_directory,
        template_id=args.template_id,
        title=args.title,
        category=args.category,
        config=ProcessingConfig(
            line_threshold=args.line_threshold,
            close_gap_pixels=args.close_gap_pixels,
            minimum_region_pixels=args.minimum_region_pixels,
            minimum_touch_dimension=args.minimum_touch_dimension,
        ),
    )
    print(
        f"Prepared {result.template_id}: {result.region_count} regions, "
        f"{result.warning_count} warnings -> {result.output_directory}"
    )


if __name__ == "__main__":
    main()
