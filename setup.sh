#!/usr/bin/env bash
set -euo pipefail

# Run from: /Users/tl10/Documents/nf-bioimage-spec
echo "Setting up nf-bioimage-spec..."

# ── Directory structure ──
mkdir -p docs
mkdir -p schemas
mkdir -p templates/monolithic/enduser
mkdir -p templates/monolithic/developer
mkdir -p templates/chunked/enduser
mkdir -p templates/chunked/developer
mkdir -p scripts
mkdir -p examples/cellpose_objseg_mono_eu
mkdir -p examples/cellpose_objseg_chnk_dev
mkdir -p .github/workflows

echo "✓ Directory structure created"

# ── schemas/categories.json ──
cat > schemas/categories.json << 'CATEOF'
[
  {
    "id": "ImgProc",
    "full_name": "ImageProcessing",
    "category": "Image Processing",
    "task": "Denoising, deconvolution, flat-field correction, filtering",
    "source": "custom"
  },
  {
    "id": "Stitch",
    "full_name": "StitchingRegistration",
    "category": "Stitching / Registration",
    "task": "Align and merge tiles or time-points into a single coordinate space",
    "source": "custom"
  },
  {
    "id": "ObjSeg",
    "full_name": "ObjectSegmentation",
    "category": "Object Segmentation",
    "task": "Delineate individual objects as distinct labelled regions",
    "source": "BIAFLOWS"
  },
  {
    "id": "PixCla",
    "full_name": "PixelVoxelClassification",
    "category": "Pixel / Voxel Classification",
    "task": "Assign each pixel to a semantic class",
    "source": "BIAFLOWS"
  },
  {
    "id": "ObjDet",
    "full_name": "SpotObjectDetection",
    "category": "Spot / Object Detection",
    "task": "Detect and localise objects (e.g. nuclei, spots)",
    "source": "BIAFLOWS"
  },
  {
    "id": "SptCnt",
    "full_name": "SpotObjectCounting",
    "category": "Spot / Object Counting",
    "task": "Estimate the number of objects",
    "source": "BIAFLOWS"
  },
  {
    "id": "LndDet",
    "full_name": "LandmarkDetection",
    "category": "Landmark Detection",
    "task": "Estimate position of specific feature points",
    "source": "BIAFLOWS"
  },
  {
    "id": "TreTrc",
    "full_name": "FilamentTreeTracing",
    "category": "Filament / Tree Tracing",
    "task": "Estimate medial axis of connected filament tree networks",
    "source": "BIAFLOWS"
  },
  {
    "id": "LooTrc",
    "full_name": "FilamentNetworkTracing",
    "category": "Filament Network Tracing",
    "task": "Estimate medial axis of filament networks (with loops)",
    "source": "BIAFLOWS"
  },
  {
    "id": "PrtTrk",
    "full_name": "ParticleTracking",
    "category": "Particle Tracking",
    "task": "Estimate tracks followed by particles (no division)",
    "source": "BIAFLOWS"
  },
  {
    "id": "ObjTrk",
    "full_name": "ObjectTracking",
    "category": "Object Tracking",
    "task": "Estimate tracks + segmentation masks (with divisions)",
    "source": "BIAFLOWS"
  },
  {
    "id": "FeatExt",
    "full_name": "FeatureExtraction",
    "category": "Feature Extraction",
    "task": "Measure morphological, intensity, or texture features",
    "source": "custom"
  },
  {
    "id": "Raster",
    "full_name": "Rasterisation",
    "category": "Rasterisation",
    "task": "Convert vector annotations to raster label masks",
    "source": "custom"
  },
  {
    "id": "Seg2Vec",
    "full_name": "SegmentationToVector",
    "category": "Segmentation to Vector",
    "task": "Convert segmentation masks to vector format",
    "source": "custom"
  }
]
CATEOF
echo "✓ schemas/categories.json"

# ── schemas/axes.json ──
cat > schemas/axes.json << 'AXEOF'
{
  "storage": {
    "monolithic": { "full": "Monolithic", "abbr": "Mono", "description": "Single-file formats (TIFF, PNG, HDF5). Module receives/emits file paths." },
    "chunked":    { "full": "Chunked",    "abbr": "Chnk", "description": "OME-Zarr/N5. Module receives zarr directory. Always internal parallelism." }
  },
  "output": {
    "image":     { "full": "Image",              "abbr": "Img" },
    "mask":      { "full": "LabelMask",           "abbr": "Msk" },
    "vector":    { "full": "Vector",              "abbr": "Vec" },
    "tabular":   { "full": "Tabular",             "abbr": "Tab" },
    "scalar":    { "full": "Scalar",              "abbr": "Scl" },
    "skeleton":  { "full": "SkeletonMask",         "abbr": "Skl" },
    "swc":       { "full": "SWC",                 "abbr": "SWC" },
    "track":     { "full": "Tracks",              "abbr": "Trk" },
    "track+div": { "full": "TracksWithDivision",   "abbr": "TrkDiv" },
    "points":    { "full": "Points",              "abbr": "Pts" },
    "classmask": { "full": "ClassMask",            "abbr": "ClsMsk" }
  },
  "parallelism": {
    "external": { "full": "External", "abbr": "Ext", "description": "Nextflow scatters FOVs/tiles to separate processes." },
    "internal": { "full": "Internal", "abbr": "Int", "description": "Module coordinates across data internally." }
  },
  "user_profile": {
    "enduser":   { "full": "EndUser",   "abbr": "EU",  "description": "Bundled models, preset params, minimal config." },
    "developer": { "full": "Developer", "abbr": "Dev", "description": "Custom models via input channel, all params exposed." }
  },
  "gpu": {
    "none":     { "label": "CPU only" },
    "optional": { "label": "GPU optional" },
    "required": { "label": "GPU required" }
  },
  "model": {
    "none":          { "label": "No model" },
    "model_bundled": { "label": "Model bundled in container" },
    "model_input":   { "label": "Model as input path channel" }
  },
  "ecosystem": {
    "python":    { "label": "Python" },
    "java_fiji": { "label": "Java / Fiji" },
    "mixed":     { "label": "Mixed" }
  },
  "io_strategy": {
    "new_file":                { "label": "New output file(s)", "idempotent": true },
    "read_only_new_file":      { "label": "Read-only zarr, write new file", "idempotent": true },
    "new_group_same_zarr":     { "label": "New array group in same zarr (e.g. /processed/)", "idempotent": true, "note": "NF stages zarr to task workdir" },
    "new_zarr_symlink_labels": { "label": "New zarr dir with symlinks to input + new labels/ group", "idempotent": true },
    "new_zarr_symlink_meta":   { "label": "New zarr dir with symlinks to input + rewritten metadata", "idempotent": true }
  },
  "dim_handling": {
    "single_plane":      "Single 2D plane",
    "per_channel_slice":  "Per channel/slice (C or Z independently)",
    "full_volume":        "Full 3D volume (XYZ together)",
    "full_stack":         "Full TCZYX stack",
    "full_timelapse":     "Full time-lapse (T required)",
    "multi_tile":         "Multi-tile / multi-FOV"
  },
  "naming_convention": {
    "pattern_full":  "{CategoryFull}_{StorageFull}_{OutputFull}_{ParallelismFull}_{UserProfileFull}",
    "pattern_abbr":  "{CategoryAbbr}_{StorageAbbr}_{OutputAbbr}_{ParallelismAbbr}_{UserProfileAbbr}",
    "process_name":  "Abbreviation uppercased",
    "module_path":   "modules/nf-core/{category_lower}/{storage}_{output}_{profile}/"
  },
  "rules": {
    "chunked_implies_internal": true,
    "nextflow_input_ne_output": true
  }
}
AXEOF
echo "✓ schemas/axes.json"

# ── schemas/variants.json ──
cat > schemas/variants.json << 'VAREOF'
[
  {"category_id":"ImgProc","storage":"monolithic","output":"image","parallelism":"external","user_profile":"enduser","gpu":"optional","model":"model_bundled","ecosystem":"python","io_strategy":"new_file","dim_handling":"per_channel_slice","nf_input":"tuple val(meta), path(image)","nf_output":"tuple val(meta), path(\"*_processed.{tif,tiff,png}\"), emit: processed","params":"preset name","qc":"PSNR/SSIM summary CSV; before/after thumbnail","meta_fields":["id","pixel_size_xy","pixel_size_z","bit_depth","n_channels"]},
  {"category_id":"ImgProc","storage":"monolithic","output":"image","parallelism":"external","user_profile":"developer","gpu":"optional","model":"model_input","ecosystem":"python","io_strategy":"new_file","dim_handling":"per_channel_slice","nf_input":"tuple val(meta), path(image), path(model_weights)","nf_output":"tuple val(meta), path(\"*_processed.{tif,tiff,png}\"), emit: processed","params":"model path, model config YAML, all hyperparameters","qc":"PSNR/SSIM summary CSV; before/after thumbnail; model metadata log","meta_fields":["id","pixel_size_xy","pixel_size_z","bit_depth","n_channels"]},
  {"category_id":"ImgProc","storage":"chunked","output":"image","parallelism":"internal","user_profile":"enduser","gpu":"optional","model":"model_bundled","ecosystem":"python","io_strategy":"new_group_same_zarr","dim_handling":"full_stack","nf_input":"tuple val(meta), path(zarr_dir)","nf_output":"tuple val(meta), path(zarr_dir), emit: processed","params":"preset name","qc":"PSNR/SSIM summary CSV; before/after thumbnail","meta_fields":["id","pixel_size_xy","pixel_size_z","bit_depth","n_channels"]},
  {"category_id":"ImgProc","storage":"chunked","output":"image","parallelism":"internal","user_profile":"developer","gpu":"optional","model":"model_input","ecosystem":"python","io_strategy":"new_group_same_zarr","dim_handling":"full_stack","nf_input":"tuple val(meta), path(zarr_dir), path(model_weights)","nf_output":"tuple val(meta), path(zarr_dir), emit: processed","params":"model path, model config, chunk overlap, all hyperparameters","qc":"PSNR/SSIM summary CSV; before/after thumbnail; model metadata log","meta_fields":["id","pixel_size_xy","pixel_size_z","bit_depth","n_channels"]},
  {"category_id":"Stitch","storage":"monolithic","output":"image","parallelism":"internal","user_profile":"enduser","gpu":"none","model":"none","ecosystem":"java_fiji","io_strategy":"new_file","dim_handling":"multi_tile","nf_input":"tuple val(meta), path(images, stageAs: 'tiles/*')","nf_output":"tuple val(meta), path(\"*_stitched.{tif,ome.tif}\"), emit: stitched","params":"fusion method","qc":"Registration error summary; overlap quality map","meta_fields":["id","pixel_size_xy","pixel_size_z","tile_layout","overlap_pct"]},
  {"category_id":"Stitch","storage":"monolithic","output":"image","parallelism":"internal","user_profile":"developer","gpu":"none","model":"none","ecosystem":"java_fiji","io_strategy":"new_file","dim_handling":"multi_tile","nf_input":"tuple val(meta), path(images, stageAs: 'tiles/*')","nf_output":"tuple val(meta), path(\"*_stitched.{tif,ome.tif}\"), emit: stitched","params":"registration method, fusion method, downsample, transform output, all params","qc":"Registration error summary; overlap quality map; transform matrices CSV","meta_fields":["id","pixel_size_xy","pixel_size_z","tile_layout","overlap_pct"]},
  {"category_id":"Stitch","storage":"chunked","output":"image","parallelism":"internal","user_profile":"enduser","gpu":"none","model":"none","ecosystem":"java_fiji","io_strategy":"new_zarr_symlink_meta","dim_handling":"multi_tile","nf_input":"tuple val(meta), path(zarr_dir)","nf_output":"tuple val(meta), path(\"${meta.id}_stitched.zarr\"), emit: stitched","params":"fusion method","qc":"Registration error summary","meta_fields":["id","pixel_size_xy","pixel_size_z","tile_layout","overlap_pct"]},
  {"category_id":"Stitch","storage":"chunked","output":"image","parallelism":"internal","user_profile":"developer","gpu":"none","model":"none","ecosystem":"java_fiji","io_strategy":"new_zarr_symlink_meta","dim_handling":"multi_tile","nf_input":"tuple val(meta), path(zarr_dir)","nf_output":"tuple val(meta), path(\"${meta.id}_stitched.zarr\"), emit: stitched","params":"all registration/fusion params","qc":"Registration error summary; transform matrices CSV","meta_fields":["id","pixel_size_xy","pixel_size_z","tile_layout","overlap_pct"]},
  {"category_id":"ObjSeg","storage":"monolithic","output":"mask","parallelism":"external","user_profile":"enduser","gpu":"optional","model":"model_bundled","ecosystem":"python","io_strategy":"new_file","dim_handling":"per_channel_slice","nf_input":"tuple val(meta), path(image)","nf_output":"tuple val(meta), path(\"*_labels.{tif,tiff}\"), emit: labels","params":"model name, diameter","qc":"Object count; mean area; segmentation overlay PNG; DICE if GT","meta_fields":["id","pixel_size_xy","pixel_size_z","n_channels","channel_names"]},
  {"category_id":"ObjSeg","storage":"monolithic","output":"mask","parallelism":"external","user_profile":"developer","gpu":"optional","model":"model_input","ecosystem":"python","io_strategy":"new_file","dim_handling":"per_channel_slice","nf_input":"tuple val(meta), path(image), path(model_weights)","nf_output":"tuple val(meta), path(\"*_labels.{tif,tiff}\"), emit: labels","params":"model path, model config, diameter, flow_threshold, cellprob_threshold, all params","qc":"Object count; mean area; overlay PNG; DICE if GT; model metadata log","meta_fields":["id","pixel_size_xy","pixel_size_z","n_channels","channel_names"]},
  {"category_id":"ObjSeg","storage":"monolithic","output":"vector","parallelism":"external","user_profile":"enduser","gpu":"optional","model":"model_bundled","ecosystem":"python","io_strategy":"new_file","dim_handling":"per_channel_slice","nf_input":"tuple val(meta), path(image)","nf_output":"tuple val(meta), path(\"*_labels.{geojson,wkt}\"), emit: polygons","params":"model name, diameter, simplify tolerance","qc":"Object count; polygon overlay PNG","meta_fields":["id","pixel_size_xy","n_channels","channel_names"]},
  {"category_id":"ObjSeg","storage":"monolithic","output":"vector","parallelism":"external","user_profile":"developer","gpu":"optional","model":"model_input","ecosystem":"python","io_strategy":"new_file","dim_handling":"per_channel_slice","nf_input":"tuple val(meta), path(image), path(model_weights)","nf_output":"tuple val(meta), path(\"*_labels.{geojson,wkt}\"), emit: polygons","params":"model path, all params, simplify tolerance","qc":"Object count; overlay PNG; model metadata log","meta_fields":["id","pixel_size_xy","n_channels","channel_names"]},
  {"category_id":"ObjSeg","storage":"chunked","output":"mask","parallelism":"internal","user_profile":"enduser","gpu":"optional","model":"model_bundled","ecosystem":"python","io_strategy":"new_zarr_symlink_labels","dim_handling":"full_stack","nf_input":"tuple val(meta), path(zarr_dir)","nf_output":"tuple val(meta), path(\"${meta.id}_seg.zarr\"), emit: labels","params":"model name, diameter","qc":"Object count; segmentation overlay PNG","meta_fields":["id","pixel_size_xy","pixel_size_z","n_channels","channel_names"]},
  {"category_id":"ObjSeg","storage":"chunked","output":"mask","parallelism":"internal","user_profile":"developer","gpu":"optional","model":"model_input","ecosystem":"python","io_strategy":"new_zarr_symlink_labels","dim_handling":"full_stack","nf_input":"tuple val(meta), path(zarr_dir), path(model_weights)","nf_output":"tuple val(meta), path(\"${meta.id}_seg.zarr\"), emit: labels","params":"model path, model config, chunk overlap, all params","qc":"Object count; overlay PNG; model metadata log","meta_fields":["id","pixel_size_xy","pixel_size_z","n_channels","channel_names"]},
  {"category_id":"PixCla","storage":"monolithic","output":"mask","parallelism":"external","user_profile":"enduser","gpu":"optional","model":"model_bundled","ecosystem":"python","io_strategy":"new_file","dim_handling":"per_channel_slice","nf_input":"tuple val(meta), path(image)","nf_output":"tuple val(meta), path(\"*_class.{tif,tiff}\"), emit: classes","params":"model name, class names","qc":"Class distribution histogram; overlay PNG; F1/accuracy if GT","meta_fields":["id","pixel_size_xy","pixel_size_z","n_channels"]},
  {"category_id":"PixCla","storage":"monolithic","output":"mask","parallelism":"external","user_profile":"developer","gpu":"optional","model":"model_input","ecosystem":"python","io_strategy":"new_file","dim_handling":"per_channel_slice","nf_input":"tuple val(meta), path(image), path(model_weights)","nf_output":"tuple val(meta), path(\"*_class.{tif,tiff}\"), emit: classes","params":"model path, config, class names, threshold, all params","qc":"Class histogram; overlay PNG; F1 if GT; model metadata log","meta_fields":["id","pixel_size_xy","pixel_size_z","n_channels"]},
  {"category_id":"PixCla","storage":"chunked","output":"mask","parallelism":"internal","user_profile":"enduser","gpu":"optional","model":"model_bundled","ecosystem":"python","io_strategy":"new_zarr_symlink_labels","dim_handling":"full_stack","nf_input":"tuple val(meta), path(zarr_dir)","nf_output":"tuple val(meta), path(\"${meta.id}_class.zarr\"), emit: classes","params":"model name, class names","qc":"Class distribution histogram; overlay PNG","meta_fields":["id","pixel_size_xy","pixel_size_z","n_channels"]},
  {"category_id":"PixCla","storage":"chunked","output":"mask","parallelism":"internal","user_profile":"developer","gpu":"optional","model":"model_input","ecosystem":"python","io_strategy":"new_zarr_symlink_labels","dim_handling":"full_stack","nf_input":"tuple val(meta), path(zarr_dir), path(model_weights)","nf_output":"tuple val(meta), path(\"${meta.id}_class.zarr\"), emit: classes","params":"model path, config, chunk overlap, all params","qc":"Class histogram; overlay PNG; model metadata log","meta_fields":["id","pixel_size_xy","pixel_size_z","n_channels"]},
  {"category_id":"ObjDet","storage":"monolithic","output":"points","parallelism":"external","user_profile":"enduser","gpu":"optional","model":"model_bundled","ecosystem":"python","io_strategy":"new_file","dim_handling":"per_channel_slice","nf_input":"tuple val(meta), path(image)","nf_output":"tuple val(meta), path(\"*_detections.{csv,tif}\"), emit: detections","params":"detector type, spot size","qc":"Detection count; overlay PNG; F1/precision/recall if GT","meta_fields":["id","pixel_size_xy","pixel_size_z","n_channels"]},
  {"category_id":"ObjDet","storage":"monolithic","output":"points","parallelism":"external","user_profile":"developer","gpu":"optional","model":"model_input","ecosystem":"python","io_strategy":"new_file","dim_handling":"per_channel_slice","nf_input":"tuple val(meta), path(image), path(model_weights)","nf_output":"tuple val(meta), path(\"*_detections.{csv,tif}\"), emit: detections","params":"model path, config, all thresholds, NMS params","qc":"Detection count; overlay PNG; F1 if GT; model metadata log","meta_fields":["id","pixel_size_xy","pixel_size_z","n_channels"]},
  {"category_id":"ObjDet","storage":"chunked","output":"tabular","parallelism":"internal","user_profile":"enduser","gpu":"optional","model":"model_bundled","ecosystem":"python","io_strategy":"read_only_new_file","dim_handling":"full_stack","nf_input":"tuple val(meta), path(zarr_dir)","nf_output":"tuple val(meta), path(\"*_detections.csv\"), emit: detections","params":"detector type, spot size","qc":"Detection count; spatial density map","meta_fields":["id","pixel_size_xy","pixel_size_z","n_channels"]},
  {"category_id":"ObjDet","storage":"chunked","output":"tabular","parallelism":"internal","user_profile":"developer","gpu":"optional","model":"model_input","ecosystem":"python","io_strategy":"read_only_new_file","dim_handling":"full_stack","nf_input":"tuple val(meta), path(zarr_dir), path(model_weights)","nf_output":"tuple val(meta), path(\"*_detections.csv\"), emit: detections","params":"model path, config, chunk overlap, dedup distance, all params","qc":"Detection count; density map; model metadata log","meta_fields":["id","pixel_size_xy","pixel_size_z","n_channels"]},
  {"category_id":"SptCnt","storage":"monolithic","output":"scalar","parallelism":"external","user_profile":"enduser","gpu":"optional","model":"model_bundled","ecosystem":"python","io_strategy":"new_file","dim_handling":"per_channel_slice","nf_input":"tuple val(meta), path(image)","nf_output":"tuple val(meta), path(\"*_counts.csv\"), emit: counts","params":"counting method, object size","qc":"Count per FOV; REC if GT","meta_fields":["id","pixel_size_xy","n_channels"]},
  {"category_id":"SptCnt","storage":"monolithic","output":"scalar","parallelism":"external","user_profile":"developer","gpu":"optional","model":"model_input","ecosystem":"python","io_strategy":"new_file","dim_handling":"per_channel_slice","nf_input":"tuple val(meta), path(image), path(model_weights)","nf_output":"tuple val(meta), path(\"*_counts.csv\"), emit: counts","params":"model path, config, all params","qc":"Count per FOV; REC if GT; model metadata log","meta_fields":["id","pixel_size_xy","n_channels"]},
  {"category_id":"SptCnt","storage":"chunked","output":"scalar","parallelism":"internal","user_profile":"enduser","gpu":"optional","model":"model_bundled","ecosystem":"python","io_strategy":"read_only_new_file","dim_handling":"full_stack","nf_input":"tuple val(meta), path(zarr_dir)","nf_output":"tuple val(meta), path(\"*_counts.csv\"), emit: counts","params":"counting method, object size","qc":"Count summary; spatial density map","meta_fields":["id","pixel_size_xy","n_channels"]},
  {"category_id":"LndDet","storage":"monolithic","output":"classmask","parallelism":"external","user_profile":"enduser","gpu":"optional","model":"model_bundled","ecosystem":"python","io_strategy":"new_file","dim_handling":"per_channel_slice","nf_input":"tuple val(meta), path(image)","nf_output":"tuple val(meta), path(\"*_landmarks.{csv,tif}\"), emit: landmarks","params":"model name, n_landmarks","qc":"Landmark count; MRE if GT; overlay PNG","meta_fields":["id","pixel_size_xy","n_channels","n_landmarks"]},
  {"category_id":"LndDet","storage":"monolithic","output":"classmask","parallelism":"external","user_profile":"developer","gpu":"optional","model":"model_input","ecosystem":"python","io_strategy":"new_file","dim_handling":"per_channel_slice","nf_input":"tuple val(meta), path(image), path(model_weights)","nf_output":"tuple val(meta), path(\"*_landmarks.{csv,tif}\"), emit: landmarks","params":"model path, config, n_landmarks, confidence threshold, all params","qc":"Landmark count; MRE if GT; overlay PNG; model metadata log","meta_fields":["id","pixel_size_xy","n_channels","n_landmarks"]},
  {"category_id":"TreTrc","storage":"monolithic","output":"swc","parallelism":"internal","user_profile":"enduser","gpu":"none","model":"none","ecosystem":"java_fiji","io_strategy":"new_file","dim_handling":"full_volume","nf_input":"tuple val(meta), path(image)","nf_output":"tuple val(meta), path(\"*_trace.swc\"), emit: traces","params":"tracing method, seed strategy","qc":"Branch count; total length; skeleton overlay; NetMets if GT","meta_fields":["id","pixel_size_xy","pixel_size_z"]},
  {"category_id":"TreTrc","storage":"monolithic","output":"swc","parallelism":"internal","user_profile":"developer","gpu":"none","model":"none","ecosystem":"java_fiji","io_strategy":"new_file","dim_handling":"full_volume","nf_input":"tuple val(meta), path(image)","nf_output":"tuple val(meta), path(\"*_trace.swc\"), emit: traces","params":"tracing method, seed strategy, pruning, gap distance, all SNT params","qc":"Branch count; total length; overlay; NetMets if GT; param dump","meta_fields":["id","pixel_size_xy","pixel_size_z"]},
  {"category_id":"LooTrc","storage":"monolithic","output":"skeleton","parallelism":"internal","user_profile":"enduser","gpu":"none","model":"none","ecosystem":"java_fiji","io_strategy":"new_file","dim_handling":"full_volume","nf_input":"tuple val(meta), path(image)","nf_output":"tuple val(meta), path(\"*_skeleton.{tif,tiff}\"), emit: skeleton","params":"skeletonisation method","qc":"Network stats; skeleton overlay; NetMets if GT","meta_fields":["id","pixel_size_xy","pixel_size_z"]},
  {"category_id":"LooTrc","storage":"monolithic","output":"skeleton","parallelism":"internal","user_profile":"developer","gpu":"none","model":"none","ecosystem":"java_fiji","io_strategy":"new_file","dim_handling":"full_volume","nf_input":"tuple val(meta), path(image)","nf_output":"tuple val(meta), path(\"*_skeleton.{tif,tiff}\"), emit: skeleton","params":"method, pruning, min branch length, all params","qc":"Network stats; overlay; NetMets if GT; param dump","meta_fields":["id","pixel_size_xy","pixel_size_z"]},
  {"category_id":"PrtTrk","storage":"monolithic","output":"track","parallelism":"internal","user_profile":"enduser","gpu":"none","model":"none","ecosystem":"java_fiji","io_strategy":"new_file","dim_handling":"full_timelapse","nf_input":"tuple val(meta), path(images, stageAs: 'frames/*')","nf_output":"tuple val(meta), path(\"*_tracks.{csv,tif}\"), emit: tracks","params":"max linking distance, max gap frames","qc":"Track count; mean displacement; overlay; FNPSB/JST if GT","meta_fields":["id","pixel_size_xy","pixel_size_z","time_interval","n_timepoints"]},
  {"category_id":"PrtTrk","storage":"monolithic","output":"track","parallelism":"internal","user_profile":"developer","gpu":"none","model":"none","ecosystem":"java_fiji","io_strategy":"new_file","dim_handling":"full_timelapse","nf_input":"tuple val(meta), path(images, stageAs: 'frames/*')","nf_output":"tuple val(meta), path(\"*_tracks.{csv,tif}\"), emit: tracks","params":"detector, linking method, max distance, gap closing, Kalman params, all","qc":"Track count; displacement; overlay; FNPSB/JST if GT; param dump","meta_fields":["id","pixel_size_xy","pixel_size_z","time_interval","n_timepoints"]},
  {"category_id":"PrtTrk","storage":"chunked","output":"track","parallelism":"internal","user_profile":"enduser","gpu":"none","model":"none","ecosystem":"python","io_strategy":"read_only_new_file","dim_handling":"full_timelapse","nf_input":"tuple val(meta), path(zarr_dir)","nf_output":"tuple val(meta), path(\"*_tracks.csv\"), emit: tracks","params":"max linking distance, max gap frames","qc":"Track count; mean displacement; overlay","meta_fields":["id","pixel_size_xy","pixel_size_z","time_interval","n_timepoints"]},
  {"category_id":"ObjTrk","storage":"monolithic","output":"track+div","parallelism":"internal","user_profile":"enduser","gpu":"optional","model":"model_bundled","ecosystem":"python","io_strategy":"new_file","dim_handling":"full_timelapse","nf_input":"tuple val(meta), path(images, stageAs: 'frames/*')","nf_output":"tuple val(meta), path(\"*_tracks/\"), emit: tracks","params":"model name / tracker type","qc":"Track count; division count; SEG/TRA if GT; lineage tree PNG","meta_fields":["id","pixel_size_xy","pixel_size_z","time_interval","n_timepoints","n_channels"]},
  {"category_id":"ObjTrk","storage":"monolithic","output":"track+div","parallelism":"internal","user_profile":"developer","gpu":"optional","model":"model_input","ecosystem":"python","io_strategy":"new_file","dim_handling":"full_timelapse","nf_input":"tuple val(meta), path(images, stageAs: 'frames/*'), path(model_weights)","nf_output":"tuple val(meta), path(\"*_tracks/\"), emit: tracks","params":"model path, config, seg params, linking params, division params, all","qc":"Track count; division count; SEG/TRA if GT; lineage PNG; model metadata log","meta_fields":["id","pixel_size_xy","pixel_size_z","time_interval","n_timepoints","n_channels"]},
  {"category_id":"ObjTrk","storage":"chunked","output":"track+div","parallelism":"internal","user_profile":"enduser","gpu":"optional","model":"model_bundled","ecosystem":"python","io_strategy":"new_zarr_symlink_labels","dim_handling":"full_timelapse","nf_input":"tuple val(meta), path(zarr_dir)","nf_output":"tuple val(meta), path(\"${meta.id}_tracked.zarr\"), emit: labels\n    tuple val(meta), path(\"*_division.txt\"), emit: divisions","params":"model name / tracker type","qc":"Track count; division count; lineage tree PNG","meta_fields":["id","pixel_size_xy","pixel_size_z","time_interval","n_timepoints","n_channels"]},
  {"category_id":"ObjTrk","storage":"chunked","output":"track+div","parallelism":"internal","user_profile":"developer","gpu":"optional","model":"model_input","ecosystem":"python","io_strategy":"new_zarr_symlink_labels","dim_handling":"full_timelapse","nf_input":"tuple val(meta), path(zarr_dir), path(model_weights)","nf_output":"tuple val(meta), path(\"${meta.id}_tracked.zarr\"), emit: labels\n    tuple val(meta), path(\"*_division.txt\"), emit: divisions","params":"model path, config, seg params, linking params, all","qc":"Track count; division count; lineage PNG; model metadata log","meta_fields":["id","pixel_size_xy","pixel_size_z","time_interval","n_timepoints","n_channels"]},
  {"category_id":"FeatExt","storage":"monolithic","output":"tabular","parallelism":"external","user_profile":"enduser","gpu":"none","model":"none","ecosystem":"python","io_strategy":"new_file","dim_handling":"per_channel_slice","nf_input":"tuple val(meta), path(image), path(labels)","nf_output":"tuple val(meta), path(\"*_features.csv\"), emit: features","params":"feature set name","qc":"Feature summary stats; correlation matrix; histogram per feature","meta_fields":["id","pixel_size_xy","pixel_size_z","n_channels","channel_names"]},
  {"category_id":"FeatExt","storage":"monolithic","output":"tabular","parallelism":"external","user_profile":"developer","gpu":"none","model":"none","ecosystem":"python","io_strategy":"new_file","dim_handling":"per_channel_slice","nf_input":"tuple val(meta), path(image), path(labels)","nf_output":"tuple val(meta), path(\"*_features.csv\"), emit: features","params":"feature list, channels, texture params","qc":"Feature summary stats; correlation matrix; histogram; param dump","meta_fields":["id","pixel_size_xy","pixel_size_z","n_channels","channel_names"]},
  {"category_id":"FeatExt","storage":"chunked","output":"tabular","parallelism":"internal","user_profile":"enduser","gpu":"none","model":"none","ecosystem":"python","io_strategy":"read_only_new_file","dim_handling":"full_stack","nf_input":"tuple val(meta), path(zarr_dir)","nf_output":"tuple val(meta), path(\"*_features.csv\"), emit: features","params":"feature set name","qc":"Feature summary stats; correlation matrix","meta_fields":["id","pixel_size_xy","pixel_size_z","n_channels","channel_names"]},
  {"category_id":"Raster","storage":"monolithic","output":"mask","parallelism":"external","user_profile":"enduser","gpu":"none","model":"none","ecosystem":"python","io_strategy":"new_file","dim_handling":"single_plane","nf_input":"tuple val(meta), path(geojson), val(image_shape)","nf_output":"tuple val(meta), path(\"*_labels.tif\"), emit: labels","params":"—","qc":"Label count; rasterised overlay PNG","meta_fields":["id","pixel_size_xy","image_width","image_height"]},
  {"category_id":"Raster","storage":"chunked","output":"mask","parallelism":"internal","user_profile":"enduser","gpu":"none","model":"none","ecosystem":"python","io_strategy":"new_zarr_symlink_labels","dim_handling":"single_plane","nf_input":"tuple val(meta), path(geojson), path(zarr_dir)","nf_output":"tuple val(meta), path(\"${meta.id}_raster.zarr\"), emit: labels","params":"—","qc":"Label count","meta_fields":["id","pixel_size_xy"]},
  {"category_id":"Seg2Vec","storage":"monolithic","output":"vector","parallelism":"external","user_profile":"enduser","gpu":"none","model":"none","ecosystem":"python","io_strategy":"new_file","dim_handling":"single_plane","nf_input":"tuple val(meta), path(labels)","nf_output":"tuple val(meta), path(\"*_polygons.geojson\"), emit: polygons","params":"simplify tolerance","qc":"Polygon count; vertex count stats","meta_fields":["id","pixel_size_xy"]},
  {"category_id":"Seg2Vec","storage":"monolithic","output":"vector","parallelism":"external","user_profile":"developer","gpu":"none","model":"none","ecosystem":"python","io_strategy":"new_file","dim_handling":"single_plane","nf_input":"tuple val(meta), path(labels)","nf_output":"tuple val(meta), path(\"*_polygons.geojson\"), emit: polygons","params":"simplify tolerance, min area, hole handling, coord transform","qc":"Polygon count; vertex stats; param dump","meta_fields":["id","pixel_size_xy"]},
  {"category_id":"Seg2Vec","storage":"chunked","output":"vector","parallelism":"internal","user_profile":"enduser","gpu":"none","model":"none","ecosystem":"python","io_strategy":"read_only_new_file","dim_handling":"single_plane","nf_input":"tuple val(meta), path(zarr_dir)","nf_output":"tuple val(meta), path(\"*_polygons.geojson\"), emit: polygons","params":"simplify tolerance","qc":"Polygon count; vertex count stats","meta_fields":["id","pixel_size_xy"]}
]
VAREOF
echo "✓ schemas/variants.json"

# ── scripts/generate_templates.py ──
cat > scripts/generate_templates.py << 'GENEOF'
#!/usr/bin/env python3
"""Generate nf-core module templates from schemas/variants.json and schemas/categories.json."""

import json
import os
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
SCHEMAS = ROOT / "schemas"
TEMPLATES = ROOT / "templates"

STORAGE_ABBR = {"monolithic": "Mono", "chunked": "Chnk"}
OUTPUT_ABBR = {
    "image": "Img", "mask": "Msk", "vector": "Vec", "tabular": "Tab",
    "scalar": "Scl", "skeleton": "Skl", "swc": "SWC", "track": "Trk",
    "track+div": "TrkDiv", "points": "Pts", "classmask": "ClsMsk",
}
PARALLEL_ABBR = {"external": "Ext", "internal": "Int"}
PROFILE_ABBR = {"enduser": "EU", "developer": "Dev"}

OUTPUT_SUFFIX = {
    "image": "_processed.tif", "mask": "_labels.tif", "vector": "_labels.geojson",
    "tabular": "_features.csv", "scalar": "_counts.csv", "skeleton": "_skeleton.tif",
    "swc": "_trace.swc", "track": "_tracks.csv", "track+div": "_tracks/",
    "points": "_detections.csv", "classmask": "_landmarks.csv",
}


def load_json(name):
    with open(SCHEMAS / name) as f:
        return json.load(f)


def abbr_name(cat, v):
    return (
        f"{cat['id']}_{STORAGE_ABBR[v['storage']]}_{OUTPUT_ABBR[v['output']]}"
        f"_{PARALLEL_ABBR[v['parallelism']]}_{PROFILE_ABBR[v['user_profile']]}"
    )


def full_name(cat, v):
    axes = load_json("axes.json")
    s = axes["storage"][v["storage"]]["full"]
    o = axes["output"][v["output"]]["full"]
    p = axes["parallelism"][v["parallelism"]]["full"]
    u = axes["user_profile"][v["user_profile"]]["full"]
    return f"{cat['full_name']}_{s}_{o}_{p}_{u}"


def version_cmd(v):
    tool = v["category_id"].lower()
    if v["ecosystem"] == "python":
        return f"python -m {tool} --version 2>&1 | sed 's/.*//g'"
    return f"fiji --headless --eval 'println(System.getProperty(\"fiji.version\"))' 2>&1 | tail -1"


def process_label(v):
    if v["gpu"] == "required":
        return "process_gpu"
    if v["gpu"] == "optional":
        return "process_medium"
    if v["parallelism"] == "internal":
        return "process_high"
    return "process_medium"


def gen_script_body(v):
    tool = v["category_id"].lower()
    io = v["io_strategy"]
    model = v["model"]
    lines = [
        'def args = task.ext.args ?: \'\'',
        'def prefix = task.ext.prefix ?: "${meta.id}"',
    ]

    if v["storage"] == "monolithic":
        cmd = f"python -m {tool}" if v["ecosystem"] == "python" else f"fiji --headless --run {tool}.groovy"
        input_flag = "$image" if "image" in v["nf_input"] else (
            "$labels" if "labels" in v["nf_input"] else "$image"
        )
        lines.append('"""')
        lines.append(f"{cmd} \\\\")
        lines.append(f"    --input {input_flag} \\\\")
        if model == "model_input":
            lines.append("    --model ${model_weights} \\\\")
        lines.append(f"    --output ${{prefix}}{OUTPUT_SUFFIX.get(v['output'], '_output.txt')} \\\\")
        lines.append("    $args")
        lines.append('"""')
    elif io == "new_group_same_zarr":
        lines.append('"""')
        lines.append(f"python -m {tool} \\\\")
        lines.append("    --input-zarr ${zarr_dir} \\\\")
        lines.append("    --output-group processed \\\\")
        if model == "model_input":
            lines.append("    --model ${model_weights} \\\\")
        lines.append("    $args")
        lines.append('"""')
    elif io in ("new_zarr_symlink_labels", "new_zarr_symlink_meta"):
        suffix = "_seg" if "Seg" in v["category_id"] else "_out"
        lines.append(f'def out_zarr = "${{prefix}}{suffix}.zarr"')
        lines.append('"""')
        lines.append("python -c \"")
        lines.append("import os; from pathlib import Path")
        lines.append("src, dst = Path('${zarr_dir}'), Path('${out_zarr}')")
        lines.append("dst.mkdir(exist_ok=True)")
        lines.append("for item in src.iterdir():")
        lines.append("    if item.name != 'labels': os.symlink(item.resolve(), dst / item.name)")
        lines.append('"')
        lines.append("")
        lines.append(f"python -m {tool} \\\\")
        lines.append("    --input-zarr ${zarr_dir} \\\\")
        lines.append("    --output-zarr ${out_zarr} \\\\")
        if model == "model_input":
            lines.append("    --model ${model_weights} \\\\")
        lines.append("    $args")
        lines.append('"""')
    else:  # read_only_new_file
        lines.append('"""')
        lines.append(f"python -m {tool} \\\\")
        lines.append("    --input-zarr ${zarr_dir} \\\\")
        lines.append(f"    --output ${{prefix}}{OUTPUT_SUFFIX.get(v['output'], '_output.txt')} \\\\")
        if model == "model_input":
            lines.append("    --model ${model_weights} \\\\")
        lines.append("    $args")
        lines.append('"""')

    return "\n    ".join(lines)


def gen_stub_body(v):
    suffix = OUTPUT_SUFFIX.get(v["output"], "_output.txt")
    return f'''def prefix = task.ext.prefix ?: "${{meta.id}}"
    """
    touch ${{prefix}}{suffix}
    """'''


def gen_main_nf(cat, v):
    aname = abbr_name(cat, v)
    fname = full_name(cat, v)
    pname = aname.upper()
    tool = v["category_id"].lower()
    eco = v["ecosystem"]
    label = process_label(v)
    vcmd = version_cmd(v)

    conda_pkg = f"bioconda::{tool}=1.0.0" if eco == "python" else f"bioconda::fiji-{tool}=1.0.0"
    container_base = tool if eco == "python" else f"fiji-{tool}"

    return f"""// Full name:    {fname}
// Abbreviation: {aname}

process {pname} {{
    tag "$meta.id"
    label '{label}'

    conda "{conda_pkg}"
    container "${{ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://depot.galaxyproject.org/singularity/{container_base}:1.0.0--pyhdfd78af_0' :
        'biocontainers/{container_base}:1.0.0--pyhdfd78af_0' }}"

    input:
    {v['nf_input']}

    output:
    {v['nf_output']}
    tuple val("${{task.process}}"), val('{tool}'), eval('{vcmd}'), emit: versions_{tool}, topic: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    {gen_script_body(v)}

    stub:
    {gen_stub_body(v)}
}}
"""


def gen_meta_yml(cat, v):
    aname = abbr_name(cat, v)
    fname = full_name(cat, v)
    tool = v["category_id"].lower()
    vcmd = version_cmd(v)

    input_section = ""
    if v["storage"] == "chunked":
        input_section += """  - zarr_dir:
      type: directory
      description: Path to OME-Zarr directory
      pattern: "*.zarr"
"""
    elif "geojson" in v["nf_input"]:
        input_section += """  - geojson:
      type: file
      description: Vector annotation file
      pattern: "*.{geojson,wkt}"
"""
    else:
        input_section += """  - image:
      type: file
      description: Input image file
      pattern: "*.{tif,tiff,png}"
"""
    if v["model"] == "model_input":
        input_section += """  - model_weights:
      type: file
      description: Path to model weights file
      pattern: "*.{pth,h5,onnx,pt}"
"""

    return f"""# Full name:    {fname}
# Abbreviation: {aname}

name: "{aname.lower()}"
description: |
  {cat['task']}
  Storage: {v['storage']} | User profile: {v['user_profile']}
keywords:
  - bioimage
  - {tool}
  - {v['storage']}
  - {v['output']}
tools:
  - "{tool}":
      description: "{cat['task']}"
      homepage: "https://github.com/example/{tool}"
      documentation: "https://github.com/example/{tool}/docs"
      licence: ["MIT"]
input:
  - meta:
      type: map
      description: |
        Groovy map containing sample metadata.
        e.g. [id: 'sample1', pixel_size_xy: 0.65, pixel_size_z: 2.0]
{input_section}output:
  - meta:
      type: map
      description: Groovy map containing sample metadata
topics:
  versions:
    - - "${{task.process}}":
          type: string
          description: The name of the process
      - "{tool}":
          type: string
          description: The name of the tool
      - "{vcmd}":
          type: eval
          description: The command used to obtain the version of the tool
"""


def gen_test(cat, v):
    aname = abbr_name(cat, v)
    fname = full_name(cat, v)
    pname = aname.upper()
    data_key = "zarr" if v["storage"] == "chunked" else "image"
    model_line = ""
    if v["model"] == "model_input":
        model_line = ",\n                    file(params.test_data['model'], checkIfExists: true)"

    return f"""// Full name:    {fname}
// Abbreviation: {aname}

nextflow_process {{
    name "Test {pname}"
    script "../main.nf"
    process "{pname}"

    test("Should run {cat['id']} {v['storage']} {v['user_profile']}") {{
        when {{
            process {{
                \"\"\"
                input[0] = [
                    [id: 'test', pixel_size_xy: 0.65],
                    file(params.test_data['{data_key}'], checkIfExists: true){model_line}
                ]
                \"\"\"
            }}
        }}
        then {{
            assertAll(
                {{ assert process.success }},
                {{ assert snapshot(process.out).match() }},
                {{ assert process.out.findAll {{ key, val -> key.startsWith('versions') }} }}
            )
        }}
    }}
}}
"""


def gen_modules_config(cat, v):
    aname = abbr_name(cat, v)
    fname = full_name(cat, v)
    pname = aname.upper()
    params = v.get("params", "")
    param_comments = "\n            ".join(f"// {p.strip()}" for p in params.split(",") if p.strip())

    return f"""// Full name:    {fname}
// Abbreviation: {aname}

process {{
    withName: '{pname}' {{
        ext.args = [
            {param_comments}
        ].join(' ')
        publishDir = [
            path: {{ "${{params.outdir}}/{cat['id'].lower()}" }},
            mode: params.publish_dir_mode,
            saveAs: {{ filename -> filename.equals('versions.yml') ? null : filename }}
        ]
    }}
}}
"""


def main():
    categories = {c["id"]: c for c in load_json("categories.json")}
    variants = load_json("variants.json")

    for v in variants:
        cat = categories[v["category_id"]]
        storage = v["storage"]
        profile = v["user_profile"]

        out_dir = TEMPLATES / storage / profile / cat["id"].lower()
        out_dir.mkdir(parents=True, exist_ok=True)
        test_dir = out_dir / "tests"
        test_dir.mkdir(exist_ok=True)

        (out_dir / "main.nf").write_text(gen_main_nf(cat, v))
        (out_dir / "meta.yml").write_text(gen_meta_yml(cat, v))
        (test_dir / "main.nf.test").write_text(gen_test(cat, v))
        (out_dir / "modules.config").write_text(gen_modules_config(cat, v))

        print(f"  ✓ {out_dir.relative_to(ROOT)}")

    print(f"\nGenerated templates for {len(variants)} variants.")


if __name__ == "__main__":
    main()
GENEOF
chmod +x scripts/generate_templates.py
echo "✓ scripts/generate_templates.py"

# ── scripts/validate_module.py ──
cat > scripts/validate_module.py << 'VALEOF'
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
VALEOF
chmod +x scripts/validate_module.py
echo "✓ scripts/validate_module.py"

# ── README.md ──
cat > README.md << 'READMEEOF'
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
READMEEOF
echo "✓ README.md"

# ── LICENSE ──
cat > LICENSE << 'LICEOF'
MIT License

Copyright (c) 2025

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
LICEOF
echo "✓ LICENSE"

# ── CONTRIBUTING.md ──
cat > CONTRIBUTING.md << 'CONTRIBEOF'
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
CONTRIBEOF
echo "✓ CONTRIBUTING.md"

# ── .github/workflows/validate.yml ──
cat > .github/workflows/validate.yml << 'CIEOF'
name: Validate templates

on:
  push:
    branches: [main]
  pull_request:
    branches: [main]

jobs:
  validate:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - uses: actions/setup-python@v5
        with:
          python-version: '3.11'

      - name: Generate templates
        run: python scripts/generate_templates.py

      - name: Validate all generated modules
        run: |
          FAILED=0
          for dir in templates/*/*/*/; do
            if [ -f "$dir/main.nf" ]; then
              python scripts/validate_module.py "$dir" || FAILED=1
            fi
          done
          exit $FAILED

      - name: Check for uncommitted changes
        run: |
          git diff --exit-code templates/ || (echo "Templates out of sync with schemas. Run generate_templates.py and commit." && exit 1)
CIEOF
echo "✓ .github/workflows/validate.yml"

# ── .gitignore ──
cat > .gitignore << 'GIEOF'
__pycache__/
*.pyc
.DS_Store
*.egg-info/
dist/
build/
.venv/
GIEOF
echo "✓ .gitignore"

# ── docs/specification.md ──
cat > docs/specification.md << 'SPECEOF'
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
SPECEOF
echo "✓ docs/specification.md"

# ── docs/naming_convention.md ──
cat > docs/naming_convention.md << 'NAMEEOF'
# Naming convention

## Pattern

```
Full:  {CategoryFull}_{StorageFull}_{OutputFull}_{ParallelismFull}_{UserProfileFull}
Abbr:  {CatAbbr}_{StorAbbr}_{OutAbbr}_{ParAbbr}_{ProfAbbr}
```

## Abbreviation tables

### Categories

| ID | Full | Abbr |
|----|------|------|
| ImgProc | ImageProcessing | ImgProc |
| Stitch | StitchingRegistration | Stitch |
| ObjSeg | ObjectSegmentation | ObjSeg |
| PixCla | PixelVoxelClassification | PixCla |
| ObjDet | SpotObjectDetection | ObjDet |
| SptCnt | SpotObjectCounting | SptCnt |
| LndDet | LandmarkDetection | LndDet |
| TreTrc | FilamentTreeTracing | TreTrc |
| LooTrc | FilamentNetworkTracing | LooTrc |
| PrtTrk | ParticleTracking | PrtTrk |
| ObjTrk | ObjectTracking | ObjTrk |
| FeatExt | FeatureExtraction | FeatExt |
| Raster | Rasterisation | Raster |
| Seg2Vec | SegmentationToVector | Seg2Vec |

### Axes

| Axis | Value | Full | Abbr |
|------|-------|------|------|
| Storage | monolithic | Monolithic | Mono |
| Storage | chunked | Chunked | Chnk |
| Output | image | Image | Img |
| Output | mask | LabelMask | Msk |
| Output | vector | Vector | Vec |
| Output | tabular | Tabular | Tab |
| Output | scalar | Scalar | Scl |
| Output | skeleton | SkeletonMask | Skl |
| Output | swc | SWC | SWC |
| Output | track | Tracks | Trk |
| Output | track+div | TracksWithDivision | TrkDiv |
| Output | points | Points | Pts |
| Output | classmask | ClassMask | ClsMsk |
| Parallelism | external | External | Ext |
| Parallelism | internal | Internal | Int |
| User profile | enduser | EndUser | EU |
| User profile | developer | Developer | Dev |

## Derived names

- **Process name**: Abbreviation uppercased → `OBJSEG_CHNK_MSK_INT_DEV`
- **Module path**: `templates/{storage}/{profile}/{category_lower}/`
- **Conda/container**: `bioconda::{tool}=x.y.z` or `bioconda::fiji-{tool}=x.y.z`
NAMEEOF
echo "✓ docs/naming_convention.md"

# ── docs/io_strategies.md ──
cat > docs/io_strategies.md << 'IOEOF'
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
IOEOF
echo "✓ docs/io_strategies.md"

# ── Generate templates ──
echo ""
echo "Generating templates from schemas..."
python3 scripts/generate_templates.py

echo ""
echo "═══════════════════════════════════════════"
echo "✓ Setup complete!"
echo ""
echo "Next steps:"
echo "  cd /Users/tl10/Documents/nf-bioimage-spec"
echo "  git add ."
echo '  git commit -m "feat: initial spec with 14 categories and ~50 module variants'
echo ""
echo "  - Category reference with branching axes"
echo "  - Naming convention (full + abbreviated)"
echo "  - I/O strategies for Nextflow idempotency"
echo "  - Templates using eval() topic channels (nf-core tools 3.5+)"
echo '  - End-user vs developer variant split"'
echo "  git push origin main"
echo "═══════════════════════════════════════════"
