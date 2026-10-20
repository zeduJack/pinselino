"""Convert line art into deterministic runtime and quality-assurance assets."""

from __future__ import annotations

from dataclasses import asdict, dataclass
from hashlib import sha256
import json
from pathlib import Path
from typing import Any

import cv2
import numpy as np
from PIL import Image


@dataclass(frozen=True)
class ProcessingConfig:
    line_threshold: int = 210
    close_gap_pixels: int = 1
    minimum_region_pixels: int = 400
    minimum_touch_dimension: int = 24

    def validate(self) -> None:
        if not 0 <= self.line_threshold <= 255:
            raise ValueError("line_threshold must be between 0 and 255")
        if self.close_gap_pixels < 0:
            raise ValueError("close_gap_pixels must not be negative")
        if self.minimum_region_pixels < 1:
            raise ValueError("minimum_region_pixels must be positive")
        if self.minimum_touch_dimension < 1:
            raise ValueError("minimum_touch_dimension must be positive")


@dataclass(frozen=True)
class ProcessingResult:
    template_id: str
    output_directory: Path
    width: int
    height: int
    region_count: int
    warning_count: int
    source_sha256: str


def _load_on_white(source: Path) -> tuple[np.ndarray, np.ndarray]:
    with Image.open(source) as opened:
        rgba = np.asarray(opened.convert("RGBA"), dtype=np.uint8)
    alpha = rgba[:, :, 3:4].astype(np.float32) / 255.0
    rgb = rgba[:, :, :3].astype(np.float32)
    composited = rgb * alpha + 255.0 * (1.0 - alpha)
    composited_u8 = np.rint(composited).astype(np.uint8)
    gray = cv2.cvtColor(composited_u8, cv2.COLOR_RGB2GRAY)
    return composited_u8, gray


def _line_mask(gray: np.ndarray, config: ProcessingConfig) -> np.ndarray:
    mask = np.where(gray <= config.line_threshold, 255, 0).astype(np.uint8)
    if config.close_gap_pixels:
        size = config.close_gap_pixels * 2 + 1
        kernel = cv2.getStructuringElement(cv2.MORPH_ELLIPSE, (size, size))
        mask = cv2.morphologyEx(mask, cv2.MORPH_CLOSE, kernel)
    return mask


def _skeleton_endpoints(line_mask: np.ndarray) -> list[tuple[int, int]]:
    work = line_mask.copy()
    skeleton = np.zeros_like(work)
    kernel = cv2.getStructuringElement(cv2.MORPH_CROSS, (3, 3))
    while cv2.countNonZero(work):
        eroded = cv2.erode(work, kernel)
        opened = cv2.dilate(eroded, kernel)
        skeleton = cv2.bitwise_or(skeleton, cv2.subtract(work, opened))
        work = eroded

    binary = (skeleton > 0).astype(np.uint8)
    neighbors = cv2.filter2D(binary, cv2.CV_16U, np.ones((3, 3), np.uint8))
    endpoints = np.argwhere((binary == 1) & (neighbors == 2))
    height, width = binary.shape
    margin = 2
    return [
        (int(x), int(y))
        for y, x in endpoints
        if margin <= x < width - margin and margin <= y < height - margin
    ]


def _encode_region_ids(region_ids: np.ndarray) -> np.ndarray:
    values = region_ids.astype(np.uint32)
    return np.stack(
        (
            (values & 0xFF).astype(np.uint8),
            ((values >> 8) & 0xFF).astype(np.uint8),
            ((values >> 16) & 0xFF).astype(np.uint8),
        ),
        axis=2,
    )


def decode_region_ids(encoded_rgb: np.ndarray) -> np.ndarray:
    """Decode the lossless RGB representation used by regions.png."""

    values = encoded_rgb.astype(np.uint32)
    return values[:, :, 0] | (values[:, :, 1] << 8) | (values[:, :, 2] << 16)


def _debug_color(region_id: int) -> tuple[int, int, int]:
    # Multipliers are coprime to 256 and keep colors deterministic.
    return (
        48 + (region_id * 83) % 192,
        48 + (region_id * 151) % 192,
        48 + (region_id * 199) % 192,
    )


def _extract_region_paths(region_ids: np.ndarray, region_count: int) -> dict[str, Any]:
    regions: list[dict[str, Any]] = []
    for region_id in range(1, region_count + 1):
        mask = np.where(region_ids == region_id, 255, 0).astype(np.uint8)
        contours, hierarchy = cv2.findContours(
            mask, cv2.RETR_CCOMP, cv2.CHAIN_APPROX_SIMPLE
        )
        paths: list[dict[str, Any]] = []
        if hierarchy is not None:
            for index, contour in enumerate(contours):
                points = [
                    [int(point[0][0]), int(point[0][1])] for point in contour
                ]
                if len(points) < 3:
                    continue
                paths.append(
                    {
                        "isHole": int(hierarchy[0][index][3]) >= 0,
                        "points": points,
                    }
                )
        regions.append({"id": region_id, "paths": paths})
    return {
        "schemaVersion": 1,
        "coordinateSpace": "image-pixels",
        "fillRule": "evenOdd",
        "regions": regions,
    }


def _write_json(path: Path, value: dict[str, Any]) -> None:
    path.write_text(
        json.dumps(value, ensure_ascii=False, indent=2, sort_keys=True) + "\n",
        encoding="utf-8",
    )


def process_coloring_page(
    source: Path,
    output_directory: Path,
    *,
    template_id: str,
    title: str,
    category: str,
    config: ProcessingConfig = ProcessingConfig(),
) -> ProcessingResult:
    """Process one image without modifying the source file."""

    config.validate()
    if not source.is_file():
        raise FileNotFoundError(source)
    if not template_id.strip():
        raise ValueError("template_id must not be empty")

    source_bytes = source.read_bytes()
    source_digest = sha256(source_bytes).hexdigest()
    _, gray = _load_on_white(source)
    height, width = gray.shape
    lines = _line_mask(gray, config)
    free_space = cv2.bitwise_not(lines)

    component_count, labels, stats, centroids = cv2.connectedComponentsWithStats(
        free_space, connectivity=8
    )
    border_labels = set(int(value) for value in labels[0, :])
    border_labels.update(int(value) for value in labels[-1, :])
    border_labels.update(int(value) for value in labels[:, 0])
    border_labels.update(int(value) for value in labels[:, -1])
    border_labels.discard(0)

    candidates: list[dict[str, Any]] = []
    for label in range(1, component_count):
        if label in border_labels:
            continue
        x, y, region_width, region_height, area = (
            int(value) for value in stats[label]
        )
        centroid_x, centroid_y = (float(value) for value in centroids[label])
        candidates.append(
            {
                "sourceLabel": label,
                "x": x,
                "y": y,
                "width": region_width,
                "height": region_height,
                "areaPixels": area,
                "centroid": [round(centroid_x, 3), round(centroid_y, 3)],
            }
        )

    # Raster-order sorting keeps IDs independent from OpenCV implementation details.
    candidates.sort(key=lambda item: (item["y"], item["x"], item["areaPixels"]))
    region_ids = np.zeros((height, width), dtype=np.uint32)
    regions: list[dict[str, Any]] = []
    warnings: list[dict[str, Any]] = []
    for region_id, candidate in enumerate(candidates, start=1):
        region_ids[labels == candidate["sourceLabel"]] = region_id
        region = {
            "id": region_id,
            "areaPixels": candidate["areaPixels"],
            "bounds": {
                "x": candidate["x"],
                "y": candidate["y"],
                "width": candidate["width"],
                "height": candidate["height"],
            },
            "centroid": candidate["centroid"],
        }
        regions.append(region)
        if candidate["areaPixels"] < config.minimum_region_pixels:
            warnings.append(
                {
                    "code": "small_region",
                    "regionId": region_id,
                    "areaPixels": candidate["areaPixels"],
                }
            )
        if min(candidate["width"], candidate["height"]) < config.minimum_touch_dimension:
            warnings.append(
                {
                    "code": "narrow_region",
                    "regionId": region_id,
                    "bounds": region["bounds"],
                }
            )

    endpoints = _skeleton_endpoints(lines)
    if endpoints:
        warnings.append(
            {
                "code": "open_contour_candidates",
                "count": len(endpoints),
                "samplePoints": [list(point) for point in endpoints[:100]],
                "message": (
                    "Line endpoints can be intentional details or gaps and require "
                    "visual review."
                ),
            }
        )
    if not regions:
        warnings.append(
            {
                "code": "no_closed_regions",
                "message": "No closed paintable region was detected.",
            }
        )

    output_directory.mkdir(parents=True, exist_ok=True)

    outline_alpha = cv2.subtract(np.full_like(gray, 255), gray)
    outline_rgba = np.zeros((height, width, 4), dtype=np.uint8)
    outline_rgba[:, :, 3] = outline_alpha
    Image.fromarray(outline_rgba).save(output_directory / "outline.png")

    encoded = _encode_region_ids(region_ids)
    Image.fromarray(encoded).save(output_directory / "regions.png")

    debug = np.full((height, width, 3), 255, dtype=np.uint8)
    for region in regions:
        debug[region_ids == region["id"]] = _debug_color(region["id"])
    debug[lines > 0] = (0, 0, 0)
    Image.fromarray(debug).save(output_directory / "debug_regions.png")

    metadata = {
        "schemaVersion": 1,
        "assetVersion": 1,
        "id": template_id,
        "title": title,
        "category": category,
        "width": width,
        "height": height,
        "outline": "outline.png",
        "regions": "regions.png",
        "regionIdEncoding": "rgb24-little-endian",
        "regionCount": len(regions),
        "sourceSha256": source_digest,
        "technicalRegions": regions,
    }
    report = {
        "schemaVersion": 1,
        "templateId": template_id,
        "source": source.name,
        "sourceSha256": source_digest,
        "configuration": asdict(config),
        "dimensions": {"width": width, "height": height},
        "linePixelCount": int(np.count_nonzero(lines)),
        "backgroundComponentCount": len(border_labels),
        "technicalRegionCount": len(regions),
        "warningCount": len(warnings),
        "warnings": warnings,
        "reviewRequired": bool(warnings),
    }
    _write_json(output_directory / "metadata.json", metadata)
    _write_json(
        output_directory / "technical_region_paths.json",
        _extract_region_paths(region_ids, len(regions)),
    )
    _write_json(output_directory / "quality_report.json", report)

    return ProcessingResult(
        template_id=template_id,
        output_directory=output_directory,
        width=width,
        height=height,
        region_count=len(regions),
        warning_count=len(warnings),
        source_sha256=source_digest,
    )
