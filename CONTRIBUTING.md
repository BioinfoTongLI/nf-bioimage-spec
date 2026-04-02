# Contributing

## Adding a new category

1. Add the category to `schemas/categories.json`
2. Add variant entries to `schemas/variants.json`
3. Run `python scripts/generate_templates.py`
4. Validate with `python scripts/validate_module.py templates/<storage>/<profile>/<category>/`
5. Submit a PR

## Modifying the template structure

Edit `scripts/generate_templates.py` and regenerate. The generated templates should match what's committed — CI will catch drift.

## Adding a concrete example

Place fully working modules (with real tool CLIs) in `examples/`. Follow the naming convention: `{tool}_{category_abbr}_{storage_abbr}_{profile_abbr}/`
