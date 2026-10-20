from __future__ import annotations

import json
from pathlib import Path
import tempfile
import unittest

import numpy as np
from PIL import Image, ImageDraw

from coloring_pipeline.processor import (
    ProcessingConfig,
    decode_region_ids,
    process_coloring_page,
)


class ProcessorTest(unittest.TestCase):
    def setUp(self) -> None:
        self.temporary_directory = tempfile.TemporaryDirectory()
        self.root = Path(self.temporary_directory.name)

    def tearDown(self) -> None:
        self.temporary_directory.cleanup()

    def _save(self, image: Image.Image, name: str = "source.png") -> Path:
        path = self.root / name
        image.save(path)
        return path

    def _process(
        self, source: Path, output_name: str = "output"
    ) -> tuple[Path, dict, dict]:
        output = self.root / output_name
        process_coloring_page(
            source,
            output,
            template_id="fixture",
            title="Fixture",
            category="tests",
            config=ProcessingConfig(
                line_threshold=180,
                close_gap_pixels=0,
                minimum_region_pixels=80,
                minimum_touch_dimension=8,
            ),
        )
        metadata = json.loads((output / "metadata.json").read_text())
        report = json.loads((output / "quality_report.json").read_text())
        return output, metadata, report

    def test_closed_neighboring_areas_receive_different_ids(self) -> None:
        image = Image.new("RGB", (120, 80), "white")
        draw = ImageDraw.Draw(image)
        draw.rectangle((10, 10, 110, 70), outline="black", width=4)
        draw.line((60, 10, 60, 70), fill="black", width=4)

        output, metadata, _ = self._process(self._save(image))
        ids = decode_region_ids(np.asarray(Image.open(output / "regions.png")))

        self.assertEqual(metadata["regionCount"], 2)
        self.assertNotEqual(int(ids[30, 30]), int(ids[30, 90]))
        self.assertGreater(int(ids[30, 30]), 0)
        self.assertEqual(int(ids[10, 30]), 0)
        self.assertEqual(int(ids[0, 0]), 0)

    def test_open_contour_is_not_reported_as_closed_region(self) -> None:
        image = Image.new("RGB", (100, 100), "white")
        draw = ImageDraw.Draw(image)
        draw.line((20, 20, 80, 20), fill="black", width=3)
        draw.line((20, 20, 20, 80), fill="black", width=3)
        draw.line((20, 80, 80, 80), fill="black", width=3)

        _, metadata, report = self._process(self._save(image))
        codes = {warning["code"] for warning in report["warnings"]}

        self.assertEqual(metadata["regionCount"], 0)
        self.assertIn("no_closed_regions", codes)
        self.assertIn("open_contour_candidates", codes)

    def test_small_region_generates_quality_warning(self) -> None:
        image = Image.new("RGB", (100, 100), "white")
        draw = ImageDraw.Draw(image)
        draw.rectangle((10, 10, 90, 90), outline="black", width=3)
        draw.rectangle((40, 40, 48, 48), outline="black", width=2)

        _, metadata, report = self._process(self._save(image))
        small = [w for w in report["warnings"] if w["code"] == "small_region"]

        self.assertEqual(metadata["regionCount"], 2)
        self.assertEqual(len(small), 1)

    def test_nested_region_produces_a_hole_in_outer_region_path(self) -> None:
        image = Image.new("RGB", (120, 120), "white")
        draw = ImageDraw.Draw(image)
        draw.rectangle((10, 10, 110, 110), outline="black", width=3)
        draw.rectangle((40, 40, 80, 80), outline="black", width=3)

        output, metadata, _ = self._process(self._save(image))
        paths = json.loads(
            (output / "technical_region_paths.json").read_text()
        )["regions"]

        self.assertEqual(metadata["regionCount"], 2)
        self.assertTrue(any(path["isHole"] for path in paths[0]["paths"]))

    def test_configured_gap_closing_can_recover_one_pixel_gap(self) -> None:
        image = Image.new("RGB", (80, 80), "white")
        draw = ImageDraw.Draw(image)
        draw.rectangle((10, 10, 70, 70), outline="black", width=3)
        draw.rectangle((39, 9, 41, 13), fill="white")
        source = self._save(image)
        output = self.root / "closed"

        result = process_coloring_page(
            source,
            output,
            template_id="closed-gap",
            title="Closed gap",
            category="tests",
            config=ProcessingConfig(
                line_threshold=180,
                close_gap_pixels=2,
                minimum_region_pixels=80,
                minimum_touch_dimension=8,
            ),
        )

        self.assertEqual(result.region_count, 1)

    def test_transparent_input_and_outputs_keep_identical_dimensions(self) -> None:
        image = Image.new("RGBA", (96, 72), (255, 255, 255, 0))
        draw = ImageDraw.Draw(image)
        draw.ellipse((12, 8, 84, 64), outline=(0, 0, 0, 255), width=4)

        output, metadata, _ = self._process(self._save(image))

        self.assertEqual((metadata["width"], metadata["height"]), (96, 72))
        for name in ("outline.png", "regions.png", "debug_regions.png"):
            with Image.open(output / name) as generated:
                self.assertEqual(generated.size, (96, 72))

    def test_processing_is_reproducible(self) -> None:
        image = Image.new("RGB", (100, 80), "white")
        draw = ImageDraw.Draw(image)
        draw.ellipse((8, 8, 45, 70), outline="black", width=3)
        draw.ellipse((55, 8, 92, 70), outline="black", width=3)
        source = self._save(image)

        first, _, _ = self._process(source, "first")
        second, _, _ = self._process(source, "second")

        for name in (
            "outline.png",
            "regions.png",
            "debug_regions.png",
            "metadata.json",
            "technical_region_paths.json",
            "quality_report.json",
        ):
            self.assertEqual((first / name).read_bytes(), (second / name).read_bytes())

    def test_rgb_id_encoding_supports_values_above_255(self) -> None:
        from coloring_pipeline.processor import _encode_region_ids

        values = np.array([[0, 1, 255, 256, 65536]], dtype=np.uint32)
        encoded = _encode_region_ids(values)

        np.testing.assert_array_equal(decode_region_ids(encoded), values)


if __name__ == "__main__":
    unittest.main()
