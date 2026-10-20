from __future__ import annotations

import json
from pathlib import Path
import tempfile
import unittest

from coloring_pipeline.grouping import build_paint_groups


class GroupingTest(unittest.TestCase):
    def setUp(self) -> None:
        self.temporary_directory = tempfile.TemporaryDirectory()
        self.root = Path(self.temporary_directory.name)
        self.processed = self.root / "processed"
        self.processed.mkdir()
        self._write(
            self.processed / "metadata.json",
            {
                "id": "fixture",
                "assetVersion": 3,
                "technicalRegions": [{"id": 1}, {"id": 2}, {"id": 3}],
            },
        )
        self._write(
            self.processed / "technical_region_paths.json",
            {
                "coordinateSpace": "image-pixels",
                "fillRule": "evenOdd",
                "regions": [
                    {"id": 1, "paths": [{"isHole": False, "points": [[0, 0], [4, 0], [4, 4]]}]},
                    {"id": 2, "paths": [{"isHole": True, "points": [[1, 1], [2, 1], [2, 2]]}]},
                    {"id": 3, "paths": [{"isHole": False, "points": [[6, 0], [8, 0], [8, 2]]}]},
                ],
            },
        )

    def tearDown(self) -> None:
        self.temporary_directory.cleanup()

    def _write(self, path: Path, value: dict) -> None:
        path.write_text(json.dumps(value), encoding="utf-8")

    def _profile(self, value: dict) -> Path:
        path = self.root / "profile.json"
        self._write(path, value)
        return path

    def test_combines_paths_and_keeps_holes(self) -> None:
        profile = self._profile(
            {
                "schemaVersion": 1,
                "profileId": "easy",
                "paintGroups": [
                    {"id": "body", "title": "Body", "regions": [1, 2]}
                ],
                "protectedRegions": [3],
            }
        )

        result = build_paint_groups(self.processed, profile, self.root / "groups.json")

        self.assertEqual(result["technicalToPaintGroup"], {"1": "body", "2": "body"})
        self.assertEqual(len(result["paintGroups"][0]["paths"]), 2)
        self.assertTrue(result["paintGroups"][0]["paths"][1]["isHole"])
        self.assertEqual(result["protectedRegions"], [3])

    def test_rejects_unknown_duplicate_and_unassigned_regions(self) -> None:
        invalid_profiles = [
            {
                "schemaVersion": 1,
                "profileId": "easy",
                "paintGroups": [{"id": "body", "regions": [1, 9]}],
                "protectedRegions": [2, 3],
            },
            {
                "schemaVersion": 1,
                "profileId": "easy",
                "paintGroups": [
                    {"id": "body", "regions": [1, 2]},
                    {"id": "detail", "regions": [2]},
                ],
                "protectedRegions": [3],
            },
            {
                "schemaVersion": 1,
                "profileId": "easy",
                "paintGroups": [{"id": "body", "regions": [1]}],
                "protectedRegions": [2],
            },
        ]
        for index, value in enumerate(invalid_profiles):
            with self.subTest(index=index), self.assertRaises(ValueError):
                build_paint_groups(
                    self.processed,
                    self._profile(value),
                    self.root / f"invalid-{index}.json",
                )

    def test_output_is_reproducible(self) -> None:
        profile = self._profile(
            {
                "schemaVersion": 1,
                "profileId": "easy",
                "paintGroups": [{"id": "body", "regions": [1, 2]}],
                "protectedRegions": [3],
            }
        )
        first = self.root / "first.json"
        second = self.root / "second.json"

        build_paint_groups(self.processed, profile, first)
        build_paint_groups(self.processed, profile, second)

        self.assertEqual(first.read_bytes(), second.read_bytes())
