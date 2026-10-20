"""Build validated, runtime-ready paint groups from technical regions."""

from __future__ import annotations

from hashlib import sha256
import json
from pathlib import Path
from typing import Any


def _load_json(path: Path) -> dict[str, Any]:
    return json.loads(path.read_text(encoding="utf-8"))


def build_paint_groups(
    processed_directory: Path,
    profile_path: Path,
    output_path: Path,
) -> dict[str, Any]:
    metadata = _load_json(processed_directory / "metadata.json")
    technical_paths = _load_json(
        processed_directory / "technical_region_paths.json"
    )
    profile = _load_json(profile_path)

    if profile.get("schemaVersion") != 1:
        raise ValueError("unsupported paint-group profile schemaVersion")
    profile_id = profile.get("profileId")
    if not isinstance(profile_id, str) or not profile_id:
        raise ValueError("profileId must be a non-empty string")

    known_ids = {region["id"] for region in metadata["technicalRegions"]}
    path_by_id = {region["id"]: region["paths"] for region in technical_paths["regions"]}
    assigned: dict[int, str] = {}
    groups: list[dict[str, Any]] = []

    for group in profile.get("paintGroups", []):
        group_id = group.get("id")
        region_ids = group.get("regions")
        if not isinstance(group_id, str) or not group_id:
            raise ValueError("every paint group needs a non-empty id")
        if not isinstance(region_ids, list) or not region_ids:
            raise ValueError(f"paint group {group_id} must contain regions")
        combined_paths: list[dict[str, Any]] = []
        for region_id in region_ids:
            if region_id not in known_ids:
                raise ValueError(f"unknown technical region {region_id}")
            if region_id in assigned:
                raise ValueError(
                    f"technical region {region_id} is assigned more than once"
                )
            assigned[region_id] = group_id
            combined_paths.extend(path_by_id[region_id])
        groups.append(
            {
                "id": group_id,
                "title": group.get("title", group_id),
                "technicalRegions": region_ids,
                "paths": combined_paths,
            }
        )

    protected = profile.get("protectedRegions", [])
    if not isinstance(protected, list):
        raise ValueError("protectedRegions must be a list")
    for region_id in protected:
        if region_id not in known_ids:
            raise ValueError(f"unknown protected region {region_id}")
        if region_id in assigned:
            raise ValueError(
                f"technical region {region_id} cannot be paintable and protected"
            )
        assigned[region_id] = "protected"

    missing = sorted(known_ids - assigned.keys())
    if missing:
        raise ValueError(f"unassigned technical regions: {missing}")

    technical_to_group = {
        str(region_id): group_id
        for region_id, group_id in sorted(assigned.items())
        if group_id != "protected"
    }
    profile_digest = sha256(profile_path.read_bytes()).hexdigest()
    result = {
        "schemaVersion": 1,
        "templateId": metadata["id"],
        "assetVersion": metadata["assetVersion"],
        "profileId": profile_id,
        "coordinateSpace": technical_paths["coordinateSpace"],
        "fillRule": technical_paths["fillRule"],
        "profileSha256": profile_digest,
        "technicalToPaintGroup": technical_to_group,
        "protectedRegions": sorted(protected),
        "paintGroups": groups,
    }
    output_path.parent.mkdir(parents=True, exist_ok=True)
    output_path.write_text(
        json.dumps(result, ensure_ascii=False, indent=2, sort_keys=True) + "\n",
        encoding="utf-8",
    )
    return result
