# agent.md — Specification changelog and design decisions

This file tracks the evolution of the nf-bioimage-spec. Every significant change to the category table, variant definitions, axes, or design decisions should be recorded here. This serves as institutional memory for the project and helps new contributors understand *why* things are the way they are.

---

## How to use this file

When you make changes to the spec, add an entry at the top of the [Changelog](#changelog) section:

```markdown
### YYYY-MM-DD — Short description

**Author**: Your Name
**PR**: #N (if applicable)
**Files changed**: schemas/variants.json, docs/categories.html, ...

**What changed**:
- Brief description of what was added/modified/removed

**Why**:
- Rationale for the change

**Discussion**:
- Link to any related discussions, issues, or references
```

---

## Design principles

These are the foundational decisions that shape the spec. Changes to these should be discussed broadly before merging.

### 1. Data-driven specification

Everything derives from `schemas/categories.json` and `schemas/variants.json`. Templates, documentation, and the website are all generated outputs. This ensures consistency — there is exactly one source of truth.

### 2. Four branching axes

Every module variant is defined by four axes:

| Axis | Options | Rationale |
|------|---------|-----------|
| **Storage** | Monolithic / Chunked | Determines Nextflow I/O contract. Chunked (OME-Zarr) requires fundamentally different process declarations than monolithic (TIFF). |
| **Output format** | Image / Mask / Vector / Tabular / Scalar / ... | Determines the output channel type and file pattern. |
| **Parallelism** | External / Internal | External = Nextflow scatters, Internal = module coordinates. Constraint: **chunked always implies internal**. |
| **User profile** | End-user / Developer | End-user gets bundled models and preset params. Developer gets model as input channel and all params exposed. |

### 3. Chunked always implies internal parallelism

When a module operates on OME-Zarr data, the tool itself handles chunk iteration. Nextflow does not scatter individual chunks to separate processes. This was chosen because:
- Many operations need cross-chunk context (overlap for segmentation, boundary deduplication for detection)
- The zarr library handles parallel chunk I/O efficiently within a single process
- It simplifies the Nextflow DAG — one process per zarr, not thousands per chunk

### 4. Nextflow input ≠ output (idempotency)

Nextflow requires distinct input and output paths. For chunked modules that write back into zarr, we use three strategies:
- **New array group**: writes `/processed/` in the same zarr (NF stages to workdir)
- **Symlinks + labels/**: new zarr dir with symlinks to original + new labels group
- **Symlinks + metadata**: new zarr dir with symlinks to original + rewritten .zattrs

### 5. User profile splits model delivery

- **End-user**: model weights bundled in container. User picks a preset name. Container is self-contained.
- **Developer**: model weights as `path(model_weights)` input channel. User can swap models per run without rebuilding containers. All hyperparameters exposed via `ext.args`.

### 6. eval() topic channels for versions

Following nf-core tools ≥ 3.5, modules use the `eval()` output qualifier with `topic: versions` instead of writing `versions.yml` files. This removes the HEREDOC boilerplate and enables pipeline-level version aggregation via topic channels.

---

## Category sources

| Source | Categories | Reference |
|--------|-----------|-----------|
| BIAFLOWS/NEUBIAS | ObjSeg, PixCla, ObjDet, SptCnt, LndDet, TreTrc, LooTrc, PrtTrk, ObjTrk | [NEUBIAS problem classes](https://neubias-wg5.github.io/problem_class_ground_truth.html) |
| Custom | ImgProc, Stitch, FeatExt, Raster, Seg2Vec | Derived from common bioimage analysis workflows |

---

## Terminology

| Term | Meaning |
|------|---------|
| **Monolithic** | Single-file formats (TIFF, PNG, HDF5) where the entire binary blob is read sequentially |
| **Chunked** | Next-gen formats (OME-Zarr, N5) where data is split into independently accessible chunks |
| **External parallelism** | Nextflow handles scatter/gather across FOVs, tiles, or time-points |
| **Internal parallelism** | The module itself coordinates across data (chunks, tiles, frames) |
| **End-user** | Biologist running production pipelines — wants minimal config |
| **Developer** | Method developer doing parameter sweeps or custom model evaluation |

---

## Changelog

### 2025-04-02 — Initial specification

**Author**: Tong LI
**Files changed**: all

**What changed**:
- Created specification with 14 analysis categories
- Defined 4 branching axes (storage, output, parallelism, user profile)
- Defined ~50 module variants with Nextflow I/O contracts
- Established naming convention (full + abbreviated forms)
- Defined 5 I/O strategies for Nextflow idempotency
- Added per-variant factors: GPU, model management, dimensionality, ecosystem, QC, meta fields
- Created template generator (`scripts/generate_templates.py`)
- Created module validator (`scripts/validate_module.py`)
- Built interactive GitHub Pages site (categories reference + template generator)
- All templates use nf-core eval() topic channels (tools ≥ 3.5)

**Why**:
- Newcomers to nf-core bioimage analysis need a systematic guide for writing modules
- The combinatorial complexity of storage format × output type × user profile creates many distinct module types, each with different Nextflow I/O contracts
- A data-driven approach ensures consistency and enables automated generation

**Sources**:
- [NEUBIAS/BIAFLOWS problem classes](https://neubias-wg5.github.io/problem_class_ground_truth.html)
- [OME-NGFF / OME-Zarr specs](https://ngff.openmicroscopy.org/latest/) (Moore et al. 2023)
- [nf-core module guidelines](https://nf-co.re/docs/guidelines/components/modules)
- [nf-core eval() topic channels](https://nf-co.re/blog/2025/version_topics)
- [OME-Zarr terminology: monolithic vs chunked](https://gerbi-gmb.de/2025/07/02/next-generation-file-formats-for-bioimaging/)

---

## Future considerations

These are topics that have been discussed but not yet resolved. If you want to work on any of these, please open an issue first.

- [ ] **Training/fine-tuning modules** — a new category for model training workflows (distinct from inference)
- [ ] **Multi-tool subworkflows** — how to compose variants into nf-core subworkflows (e.g. denoise → segment → extract features)
- [ ] **Benchmark/evaluation modules** — standardised modules that compute metrics (DICE, F1, etc.) against ground truth
- [ ] **Format conversion modules** — TIFF↔OME-Zarr, HDF5↔Zarr, etc. as first-class category
- [ ] **Cloud storage integration** — S3/GCS paths as input, cloud-native chunk access patterns
- [ ] **GPU container variants** — separate container tags for CUDA vs CPU-only builds
- [ ] **Meta map standardisation** — formal schema for `val(meta)` fields across all categories
- [ ] **Integration with bioimage.io** — aligning model delivery with bioimage.io model zoo format
