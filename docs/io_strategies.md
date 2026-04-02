# I/O strategies

## The Nextflow constraint

Nextflow requires that process outputs are distinct from inputs at the filesystem level. A process cannot declare the same path as both input and output.

## Strategies for chunked (OME-Zarr) modules

### 1. New array group in same zarr

**Used by**: Image processing (denoising, deconvolution)

The tool writes a new array group (e.g. `/processed/`) inside the zarr. Original image arrays are untouched. Nextflow stages the zarr to the task working directory first, so the "original" in the workdir is a copy.

```
input zarr/          →  workdir zarr/
  ├── 0/                   ├── 0/           (original)
  └── .zattrs              ├── processed/   (NEW)
                           └── .zattrs
```

### 2. New zarr with symlinks + labels/

**Used by**: Segmentation, classification, rasterisation, object tracking

Creates an entirely new zarr directory. Image array paths are symlinks back to the input zarr. The `labels/` group is freshly written.

```
input.zarr/          →  output_seg.zarr/
  ├── 0/                   ├── 0 → ../input.zarr/0   (symlink)
  └── .zattrs              ├── labels/                (NEW)
                           │   └── 0/
                           └── .zattrs → ../input.zarr/.zattrs
```

### 3. New zarr with symlinks + rewritten metadata

**Used by**: Stitching, registration

Same symlink approach, but the new content is rewritten `.zattrs` / coordinate transforms rather than label arrays.

```
input.zarr/          →  output_stitched.zarr/
  ├── 0/                   ├── 0 → ../input.zarr/0   (symlink)
  └── .zattrs              └── .zattrs               (REWRITTEN)
```

### 4. Read-only zarr → new file

**Used by**: Detection, counting, feature extraction, vectorisation

The module reads from the zarr without modification and writes output to a completely separate file (CSV, GeoJSON). Trivially idempotent.

```
input.zarr/  (unchanged)  →  output_detections.csv  (NEW)
```
