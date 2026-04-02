# Bioimage Analysis Module Specification

## Branching axes

Every module variant is defined by four axes:

### 1. Storage format

- **Monolithic**: Single-file formats (TIFF, PNG, HDF5). Module receives and emits file paths.
- **Chunked (OME-Zarr)**: Data split into independently accessible chunks. Module receives zarr directory path. **Always uses internal parallelism.**

### 2. Output format

Image, Label mask, Vector (GeoJSON/WKT), Tabular (CSV), Scalar, Skeleton mask, SWC, Tracks, Tracks+Division, Points, Class mask.

### 3. Parallelism

- **External**: Nextflow scatters FOVs/tiles/frames to separate processes. Module processes one unit.
- **Internal**: Module itself coordinates across data. Multi-threading/GPU within the process.

### 4. User profile

- **End-user**: Model weights bundled in container. Preset params. Minimal configuration.
- **Developer**: Model weights as Nextflow input channel. All hyperparameters exposed.

## I/O strategies for Nextflow idempotency

Nextflow requires distinct input and output paths. For chunked modules:

| Strategy | Use case | How it works |
|----------|----------|--------------|
| New array group in same zarr | Image processing | Writes /processed/ group. NF stages zarr to workdir. |
| New zarr (symlinks + labels/) | Segmentation, classification, rasterisation | New zarr dir with symlinks to input image chunks + new labels/ group. |
| New zarr (symlinks + metadata) | Stitching, registration | New zarr dir with symlinks to input chunks + rewritten .zattrs. |
| Read-only zarr → new file | Detection, counting, feature extraction | Reads zarr unchanged, outputs CSV/GeoJSON. |

## Version reporting

All modules use the nf-core eval() topic channel pattern (tools ≥ 3.5):

```nextflow
output:
tuple val("${task.process}"), val('toolname'), eval('toolname --version'), emit: versions_toolname, topic: versions
```

## Additional per-variant factors

- **GPU**: CPU only / GPU optional / GPU required
- **Model management**: No model / Bundled in container / Input path channel
- **Dimensionality**: Single plane / Per channel-slice / Full volume / Full stack / Full timelapse / Multi-tile
- **Container ecosystem**: Python (BioContainers) / Java-Fiji / Mixed
- **QC outputs**: Each module emits secondary QC (overlay PNGs, summary CSVs, metrics if GT available)
- **Meta map fields**: `val(meta)` carries pixel_size_xy, pixel_size_z, n_channels, etc.
