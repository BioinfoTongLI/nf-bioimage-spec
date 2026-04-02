#!/usr/bin/env python3
"""Rebuild docs/categories.html by re-injecting data from schemas.

Run this after modifying schemas/categories.json or schemas/variants.json
to update the interactive categories page.
"""

import json
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
SCHEMAS = ROOT / "schemas"
DOCS = ROOT / "docs"


def build_page_data():
    """Build the DATA array that categories.html expects."""
    cats = json.loads((SCHEMAS / "categories.json").read_text())
    variants = json.loads((SCHEMAS / "variants.json").read_text())

    io_notes = {
        "new_file": "New output file. Fully idempotent, -resume safe.",
        "read_only_new_file": "Reads zarr unchanged, writes new file. Idempotent.",
        "new_group_same_zarr": "New array group in same zarr. Original untouched. NF stages to workdir.",
        "new_zarr_symlink_labels": "New zarr: symlinks to input + new labels/ group. Input unmodified.",
        "new_zarr_symlink_meta": "New zarr: symlinks to input + rewritten metadata. Input unmodified.",
    }

    data = []
    for c in cats:
        cvars = [v for v in variants if v["category_id"] == c["id"]]
        if not cvars:
            continue
        entry = {
            "id": c["id"],
            "category": c["category"],
            "task": c["task"],
            "source": c["source"],
            "variants": [],
        }
        for v in cvars:
            entry["variants"].append({
                "storage": v["storage"],
                "output": v["output"],
                "parallelism": v["parallelism"],
                "userProfile": v["user_profile"],
                "gpu": v["gpu"],
                "model": v["model"],
                "ecosystem": v["ecosystem"],
                "ioStrategy": v["io_strategy"],
                "dimHandling": v["dim_handling"],
                "nfInput": v["nf_input"],
                "nfOutput": v["nf_output"],
                "params": v.get("params", ""),
                "qc": v.get("qc", ""),
                "metaFields": v.get("meta_fields", ["id"]),
                "ioNote": io_notes.get(v["io_strategy"], ""),
                "note": "",
            })
        data.append(entry)
    return data


def main():
    data = build_page_data()
    data_json = json.dumps(data, separators=(",", ":"))

    html_path = DOCS / "categories.html"
    html = html_path.read_text()

    # Find and replace the DATA blob
    marker = "const DATA = "
    start = html.find(marker)
    if start == -1:
        print("ERROR: Could not find 'const DATA = ' in categories.html")
        return

    start += len(marker)
    # Find the matching semicolon — scan for it accounting for nested brackets
    depth = 0
    i = start
    while i < len(html):
        if html[i] == "[":
            depth += 1
        elif html[i] == "]":
            depth -= 1
            if depth == 0:
                end = i + 1
                break
        i += 1
    else:
        print("ERROR: Could not find end of DATA array")
        return

    html = html[:start] + data_json + html[end:]
    html_path.write_text(html)
    print(f"✓ Rebuilt {html_path.relative_to(ROOT)} with {len(data)} categories")


if __name__ == "__main__":
    main()
