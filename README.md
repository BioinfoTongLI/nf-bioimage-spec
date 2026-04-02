# nf-bioimage-spec

Specification and templates for nf-core bioimage analysis modules.

## Overview

This repository defines a systematic categorisation of bioimage analysis modules for nf-core pipelines, with concrete Nextflow I/O contracts for each combination of:

| Axis | Options |
|------|---------|
| **Storage** | Monolithic (TIFF, HDF5) · Chunked (OME-Zarr) |
| **Output format** | Image · Label mask · Vector · Tabular · Scalar · Skeleton · SWC · Tracks |
| **Parallelism** | External (Nextflow scatter) · Internal (in-module) |
| **User profile** | End-user (bundled models) · Developer (model as input channel) |

**Rule:** Chunked storage always implies internal parallelism.

## Categories

14 analysis categories, derived from [NEUBIAS/BIAFLOWS](https://neubias-wg5.github.io/problem_class_ground_truth.html) problem classes and custom utility types:

| Abbr | Full name | Source |
|------|-----------|--------|
| ImgProc | Image Processing | Custom |
| Stitch | Stitching / Registration | Custom |
| ObjSeg | Object Segmentation | BIAFLOWS |
| PixCla | Pixel / Voxel Classification | BIAFLOWS |
| ObjDet | Spot / Object Detection | BIAFLOWS |
| SptCnt | Spot / Object Counting | BIAFLOWS |
| LndDet | Landmark Detection | BIAFLOWS |
| TreTrc | Filament / Tree Tracing | BIAFLOWS |
| LooTrc | Filament Network Tracing | BIAFLOWS |
| PrtTrk | Particle Tracking | BIAFLOWS |
| ObjTrk | Object Tracking | BIAFLOWS |
| FeatExt | Feature Extraction | Custom |
| Raster | Rasterisation | Custom |
| Seg2Vec | Segmentation to Vector | Custom |

## Naming convention

```
Full:  {Category}_{Storage}_{Output}_{Parallelism}_{UserProfile}
Abbr:  {CatAbbr}_{StorAbbr}_{OutAbbr}_{ParAbbr}_{ProfAbbr}

Example:
  Full:  ObjectSegmentation_Chunked_LabelMask_Internal_Developer
  Abbr:  ObjSeg_Chnk_Msk_Int_Dev
  Process: OBJSEG_CHNK_MSK_INT_DEV
  Path:  templates/chunked/developer/objseg/
```

## I/O strategies

| Strategy | When | Idempotent |
|----------|------|------------|
| New file | Monolithic modules producing separate output files | ✓ |
| Read-only zarr → new file | Chunked modules producing CSV/GeoJSON | ✓ |
| New array group in same zarr | Image processing writing /processed/ group | ✓ (NF stages to workdir) |
| New zarr (symlinks + labels/) | Segmentation/classification adding labels | ✓ |
| New zarr (symlinks + metadata) | Stitching rewriting transforms | ✓ |

## Quick start

```bash
# Generate all templates from schemas
python scripts/generate_templates.py

# Validate a generated module
python scripts/validate_module.py templates/monolithic/enduser/objseg/
```

## Per-variant factors

Each variant specifies: GPU requirement, model management strategy, dimensionality handling, container ecosystem (Python/Java), QC outputs, and expected `val(meta)` fields.

Templates use the nf-core `eval()` topic channel pattern for version reporting (nf-core/tools ≥ 3.5).

## Sources

- [NEUBIAS/BIAFLOWS problem classes](https://neubias-wg5.github.io/problem_class_ground_truth.html)
- [OME-NGFF / OME-Zarr specs](https://ngff.openmicroscopy.org/latest/) (Moore et al. 2023)
- [nf-core module guidelines](https://nf-co.re/docs/guidelines/components/modules)
- [nf-core eval() topic channels](https://nf-co.re/blog/2025/version_topics)

## License

MIT
