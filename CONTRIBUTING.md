# Contributing to nf-bioimage-spec

Thank you for your interest in improving the bioimage analysis module specification! This guide walks you through every type of contribution — from fixing a typo to adding an entirely new analysis category.

## Table of contents

- [Quick overview](#quick-overview)
- [Repository structure](#repository-structure)
- [How to add a new category](#how-to-add-a-new-category)
- [How to add a new variant to an existing category](#how-to-add-a-new-variant-to-an-existing-category)
- [How to modify existing variants](#how-to-modify-existing-variants)
- [How to update the website](#how-to-update-the-website)
- [How to add a concrete example module](#how-to-add-a-concrete-example-module)
- [Naming convention reference](#naming-convention-reference)
- [Validation and CI](#validation-and-ci)
- [Submitting your contribution](#submitting-your-contribution)

---

## Quick overview

The specification is **data-driven**. Everything flows from two JSON files:

```
schemas/categories.json   ← defines the 14+ analysis categories
schemas/variants.json     ← defines all ~50+ module variants with NF I/O contracts
```

From these, we **generate**:
- `templates/` — nf-core module scaffolds (main.nf, meta.yml, tests, config)
- `docs/` — the interactive website (GitHub Pages)

**Golden rule**: edit the JSON schemas first, then regenerate everything else.

---

## Repository structure

```
nf-bioimage-spec/
├── schemas/
│   ├── categories.json       # Category definitions (source of truth)
│   ├── variants.json         # All variant definitions (source of truth)
│   └── axes.json             # Axis definitions, abbreviations, rules
├── templates/                # Generated nf-core module templates
│   ├── monolithic/
│   │   ├── enduser/{category}/
│   │   └── developer/{category}/
│   └── chunked/
│       ├── enduser/{category}/
│       └── developer/{category}/
├── scripts/
│   ├── generate_templates.py # Generates templates/ from schemas/
│   └── validate_module.py    # Lints a generated module
├── docs/
│   ├── index.html            # Landing page (GitHub Pages)
│   ├── categories.html       # Interactive category reference
│   ├── templates.html        # Interactive template generator
│   ├── categories_data.json  # Copy of schemas data for the website
│   ├── variants_data.json    # Copy of schemas data for the website
│   ├── specification.md      # Human-readable spec
│   ├── naming_convention.md  # Abbreviation tables
│   └── io_strategies.md      # I/O strategy documentation
├── examples/                 # Fully working reference modules
├── agent.md                  # Changelog and design decisions
├── CONTRIBUTING.md           # This file
├── README.md
└── LICENSE
```

---

## How to add a new category

**Example**: You want to add "Image Registration" as a new category.

### Step 1: Edit `schemas/categories.json`

Add a new entry to the JSON array:

```json
{
  "id": "ImgReg",
  "full_name": "ImageRegistration",
  "category": "Image Registration",
  "task": "Align images from different time-points, channels, or modalities",
  "source": "custom"
}
```

**Fields**:
- `id` — Short unique identifier. Used in process names and paths. Use PascalCase, 3-7 chars.
- `full_name` — PascalCase, no spaces. Used in the full naming convention.
- `category` — Human-readable display name.
- `task` — One-line description of what this category does.
- `source` — `"custom"` for new categories, `"BIAFLOWS"` for NEUBIAS problem classes.

### Step 2: Add abbreviation to `schemas/axes.json`

In the `naming_convention` section, the category abbreviation is derived from `id`, so no change needed there. But if your category needs a new output type, add it to the `output` section.

### Step 3: Add variants to `schemas/variants.json`

Add at least the minimum variants. Each combination of (storage × output × user_profile) that makes sense for your category needs an entry:

```json
{
  "category_id": "ImgReg",
  "storage": "monolithic",
  "output": "image",
  "parallelism": "internal",
  "user_profile": "enduser",
  "gpu": "none",
  "model": "none",
  "ecosystem": "python",
  "io_strategy": "new_file",
  "dim_handling": "full_volume",
  "nf_input": "tuple val(meta), path(fixed), path(moving)",
  "nf_output": "tuple val(meta), path(\"*_registered.{tif,tiff}\"), emit: registered",
  "params": "registration method, metric",
  "qc": "Registration error; overlay PNG; transform matrix",
  "meta_fields": ["id", "pixel_size_xy", "pixel_size_z"]
}
```

**Required fields for each variant**:

| Field | Description | Example values |
|-------|-------------|----------------|
| `category_id` | Must match a category `id` | `"ImgReg"` |
| `storage` | `"monolithic"` or `"chunked"` | |
| `output` | Output format key | `"image"`, `"mask"`, `"vector"`, `"tabular"`, `"scalar"`, etc. |
| `parallelism` | `"external"` or `"internal"` | Chunked → always `"internal"` |
| `user_profile` | `"enduser"` or `"developer"` | |
| `gpu` | `"none"`, `"optional"`, or `"required"` | |
| `model` | `"none"`, `"model_bundled"`, or `"model_input"` | |
| `ecosystem` | `"python"`, `"java_fiji"`, or `"mixed"` | |
| `io_strategy` | See I/O strategies below | |
| `dim_handling` | Dimensionality key | `"single_plane"`, `"per_channel_slice"`, `"full_volume"`, `"full_stack"`, `"full_timelapse"`, `"multi_tile"` |
| `nf_input` | Nextflow input tuple declaration | |
| `nf_output` | Nextflow output tuple declaration | |
| `params` | Comma-separated parameter names | |
| `qc` | Expected QC outputs | |
| `meta_fields` | List of expected `val(meta)` keys | |

**I/O strategy reference**:

| Strategy | When to use |
|----------|-------------|
| `new_file` | Monolithic → produces new output file(s) |
| `read_only_new_file` | Chunked → reads zarr unchanged, writes CSV/GeoJSON |
| `new_group_same_zarr` | Chunked → writes new array group (e.g. /processed/) in zarr |
| `new_zarr_symlink_labels` | Chunked → new zarr with symlinks + labels/ group |
| `new_zarr_symlink_meta` | Chunked → new zarr with symlinks + rewritten metadata |

### Step 4: Regenerate templates

```bash
python scripts/generate_templates.py
```

### Step 5: Update the website

```bash
# Copy updated schemas to docs/
cp schemas/categories.json docs/categories_data.json
cp schemas/variants.json docs/variants_data.json

# Escape ${ for JavaScript safety
python3 -c "
from pathlib import Path
v = Path('docs/variants_data.json').read_text()
Path('docs/variants_data.json').write_text(v.replace('\${', '\\\${'))
"
```

The categories page (`docs/categories.html`) has data inlined — you need to regenerate it:

```bash
python scripts/generate_templates.py  # also regenerates categories page data
```

Or manually re-run the data injection (see `scripts/update_website.sh` if available).

### Step 6: Validate

```bash
# Validate all generated modules
for dir in templates/*/*/*/; do
  if [ -f "$dir/main.nf" ]; then
    python scripts/validate_module.py "$dir"
  fi
done
```

### Step 7: Update agent.md

Add a changelog entry to `agent.md` documenting what you added and why.

### Step 8: Submit PR

```bash
git add .
git commit -m "feat: add ImageRegistration category with N variants"
git push origin your-branch
# Open PR on GitHub
```

---

## How to add a new variant to an existing category

Same as above, but skip Step 1. Just add the new variant object to `schemas/variants.json` and regenerate.

**Common reasons to add a variant**:
- A category now supports chunked/OME-Zarr processing
- A new output format is needed (e.g. ObjSeg now outputs GeoJSON)
- A developer variant is needed for a category that only had end-user

---

## How to modify existing variants

1. Find the variant in `schemas/variants.json`
2. Edit the field(s) you want to change
3. Regenerate: `python scripts/generate_templates.py`
4. Update website: copy schemas to `docs/`
5. Update `agent.md` with the rationale for the change
6. Submit PR

**Common modifications**:
- Changing `nf_input` / `nf_output` tuple structure
- Adding new `meta_fields`
- Updating `params` for a tool
- Changing `io_strategy` (e.g. after discussing Nextflow idempotency)

---

## How to update the website

The website (`docs/*.html`) consists of three pages:

| Page | Data source | Update method |
|------|-------------|---------------|
| `index.html` | Static | Edit directly |
| `categories.html` | Inlined from schemas | Re-run data injection (see below) |
| `templates.html` | Fetches `categories_data.json` + `variants_data.json` | Copy schemas to `docs/` |

### Quick update after schema changes

```bash
# 1. Copy schemas for the templates page
cp schemas/categories.json docs/categories_data.json
cp schemas/variants.json docs/variants_data.json
python3 -c "
from pathlib import Path
v = Path('docs/variants_data.json').read_text()
Path('docs/variants_data.json').write_text(v.replace('\${', '\\\${'))
"

# 2. Regenerate categories page (data is inlined)
# Run the injection script that was used during setup
python3 scripts/rebuild_categories_page.py

# 3. Commit and push
git add docs/
git commit -m "docs: update website with latest schema changes"
git push origin main
```

### Editing page layout or styling

The HTML pages are self-contained vanilla JS — no build tools needed. Edit them directly:

- `docs/categories.html` — category reference UI
- `docs/templates.html` — template generator UI
- `docs/index.html` — landing page

After editing, test locally by opening the files in a browser. For the templates page, you need a local server since it fetches JSON:

```bash
cd docs/
python3 -m http.server 8000
# Open http://localhost:8000
```

---

## How to add a concrete example module

Place fully working modules in `examples/`. These are real implementations (e.g. Cellpose, StarDist) rather than scaffolds.

### Naming convention

```
examples/{tool}_{category_abbr}_{storage_abbr}_{profile_abbr}/
```

Example: `examples/cellpose_ObjSeg_Mono_EU/`

### Required files

```
examples/cellpose_ObjSeg_Mono_EU/
├── main.nf           # Working process with real CLI commands
├── meta.yml          # Populated with real tool info
├── modules.config    # Real ext.args with sensible defaults
└── tests/
    └── main.nf.test  # Working test with real test data paths
```

---

## Naming convention reference

```
Pattern:
  Full:    {CategoryFull}_{StorageFull}_{OutputFull}_{ParallelismFull}_{UserProfileFull}
  Abbr:    {CatAbbr}_{StorAbbr}_{OutAbbr}_{ParAbbr}_{ProfAbbr}
  Process: ABBR uppercased
  Path:    templates/{storage}/{profile}/{category_lower}/

Example:
  Full:    ObjectSegmentation_Chunked_LabelMask_Internal_Developer
  Abbr:    ObjSeg_Chnk_Msk_Int_Dev
  Process: OBJSEG_CHNK_MSK_INT_DEV
  Path:    templates/chunked/developer/objseg/
```

See `docs/naming_convention.md` for complete abbreviation tables.

---

## Validation and CI

GitHub Actions automatically:
1. Regenerates templates from schemas
2. Validates every generated module
3. Checks that templates match the committed versions (catches schema drift)

Run locally before pushing:

```bash
python scripts/generate_templates.py
python scripts/validate_module.py templates/monolithic/enduser/objseg/
```

---

## Submitting your contribution

1. Fork the repo
2. Create a branch: `git checkout -b feat/my-new-category`
3. Make your changes following this guide
4. Update `agent.md` with a changelog entry
5. Run validation locally
6. Push and open a PR
7. Describe what you changed and why in the PR description

### PR checklist

- [ ] Edited `schemas/categories.json` and/or `schemas/variants.json`
- [ ] Ran `python scripts/generate_templates.py`
- [ ] Updated `docs/` website data files
- [ ] Ran validation on generated modules
- [ ] Added changelog entry to `agent.md`
- [ ] Tested website locally (`python3 -m http.server 8000` in `docs/`)

### What makes a good PR

- **One concern per PR** — don't mix a new category with a naming convention change
- **Explain the "why"** — especially for I/O strategy choices and axis decisions
- **Include context** — link to relevant nf-core discussions, BIAFLOWS docs, or OME-NGFF specs
- **Test the website** — open categories.html and templates.html locally to verify your changes render correctly
