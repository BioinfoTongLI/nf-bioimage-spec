#!/usr/bin/env python3
"""Validate that a generated module follows the spec conventions."""

import json
import re
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
SCHEMAS = ROOT / "schemas"


def load_json(name):
    with open(SCHEMAS / name) as f:
        return json.load(f)


def validate_main_nf(path):
    text = path.read_text()
    errors = []

    # Check eval() topic pattern
    if "topic: versions" not in text:
        errors.append("Missing 'topic: versions' in output block — use eval() pattern")
    if "versions.yml" in text and "saveAs" not in text:
        errors.append("Found versions.yml reference — migrate to eval() topic channel")

    # Check tag
    if 'tag "$meta.id"' not in text:
        errors.append("Missing tag directive")

    # Check label
    if not re.search(r"label\s+'process_", text):
        errors.append("Missing or invalid process label")

    # Check when block
    if "task.ext.when" not in text:
        errors.append("Missing 'when' block with task.ext.when")

    # Check stub block
    if "stub:" not in text:
        errors.append("Missing stub block")

    return errors


def validate_meta_yml(path):
    text = path.read_text()
    errors = []

    if "topics:" not in text:
        errors.append("Missing 'topics:' section — use new meta.yml format")
    if "type: eval" not in text:
        errors.append("Missing eval type in topics/versions")

    return errors


def main():
    if len(sys.argv) < 2:
        print("Usage: validate_module.py <module_dir>")
        sys.exit(1)

    module_dir = Path(sys.argv[1])
    all_errors = []

    main_nf = module_dir / "main.nf"
    if main_nf.exists():
        errs = validate_main_nf(main_nf)
        all_errors.extend((str(main_nf), e) for e in errs)
    else:
        all_errors.append((str(module_dir), "main.nf not found"))

    meta_yml = module_dir / "meta.yml"
    if meta_yml.exists():
        errs = validate_meta_yml(meta_yml)
        all_errors.extend((str(meta_yml), e) for e in errs)

    if all_errors:
        print(f"FAILED — {len(all_errors)} issue(s):")
        for path, err in all_errors:
            print(f"  ✗ {path}: {err}")
        sys.exit(1)
    else:
        print(f"PASSED — {module_dir}")
        sys.exit(0)


if __name__ == "__main__":
    main()
