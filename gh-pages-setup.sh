#!/usr/bin/env bash
set -euo pipefail

cd /Users/tl10/Documents/nf-bioimage-spec

mkdir -p docs/site

# ── docs/site/index.html — Landing page ──
cat > docs/site/index.html << 'INDEXEOF'
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>nf-bioimage-spec</title>
<style>
  * { box-sizing: border-box; margin: 0; padding: 0; }
  body { font-family: system-ui, -apple-system, sans-serif; background: #f8fafc; color: #1e293b; padding: 40px 20px; }
  .container { max-width: 720px; margin: 0 auto; }
  h1 { font-size: 28px; font-weight: 700; margin-bottom: 8px; }
  .subtitle { font-size: 15px; color: #64748b; margin-bottom: 32px; }
  .card { background: #fff; border: 1.5px solid #e2e8f0; border-radius: 12px; padding: 24px; margin-bottom: 16px; text-decoration: none; color: inherit; display: block; transition: border-color 0.15s, box-shadow 0.15s; }
  .card:hover { border-color: #94a3b8; box-shadow: 0 4px 12px rgba(0,0,0,0.06); }
  .card h2 { font-size: 18px; font-weight: 700; margin-bottom: 6px; }
  .card p { font-size: 14px; color: #475569; line-height: 1.5; }
  .badge { display: inline-block; font-size: 11px; font-weight: 600; padding: 2px 8px; border-radius: 6px; margin-right: 6px; }
  .badge-purple { background: #eef2ff; color: #4f46e5; border: 1px solid #a5b4fc; }
  .badge-green { background: #ecfdf5; color: #059669; border: 1px solid #6ee7b7; }
  .footer { margin-top: 32px; font-size: 12px; color: #94a3b8; }
  .footer a { color: #64748b; }
</style>
</head>
<body>
<div class="container">
  <h1>nf-bioimage-spec</h1>
  <p class="subtitle">Specification and templates for nf-core bioimage analysis modules</p>

  <a class="card" href="categories.html">
    <div>
      <span class="badge badge-green">Interactive</span>
      <span class="badge badge-purple">14 categories</span>
    </div>
    <h2>Module category reference</h2>
    <p>Browse all analysis categories with branching axes: storage format, output type, parallelism strategy, user profile. Each variant shows Nextflow I/O contracts, GPU requirements, model management, QC outputs, and meta fields.</p>
  </a>

  <a class="card" href="templates.html">
    <div>
      <span class="badge badge-green">Interactive</span>
      <span class="badge badge-purple">~50 variants</span>
    </div>
    <h2>Template generator</h2>
    <p>Select a category and variant to generate complete nf-core module files: main.nf, meta.yml, test/main.nf.test, and modules.config. Uses eval() topic channels (nf-core tools ≥ 3.5).</p>
  </a>

  <a class="card" href="https://github.com/BioinfoTongLI/nf-bioimage-spec">
    <h2>GitHub repository</h2>
    <p>Source code, JSON schemas, generation scripts, and documentation.</p>
  </a>

  <div class="footer">
    Sources: <a href="https://neubias-wg5.github.io/problem_class_ground_truth.html">BIAFLOWS/NEUBIAS</a> · <a href="https://ngff.openmicroscopy.org/latest/">OME-NGFF</a> · <a href="https://nf-co.re/docs/guidelines/components/modules">nf-core</a>
  </div>
</div>
</body>
</html>
INDEXEOF
echo "✓ docs/site/index.html"

# ── docs/site/categories.html — Full category reference app ──
cat > docs/site/categories.html << 'CATEOF'
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>Module categories — nf-bioimage-spec</title>
<script src="https://cdnjs.cloudflare.com/ajax/libs/react/18.2.0/umd/react.production.min.js"></script>
<script src="https://cdnjs.cloudflare.com/ajax/libs/react-dom/18.2.0/umd/react-dom.production.min.js"></script>
<script src="https://cdnjs.cloudflare.com/ajax/libs/babel-standalone/7.23.9/babel.min.js"></script>
<style>
  * { box-sizing: border-box; margin: 0; padding: 0; }
  body { font-family: system-ui, -apple-system, sans-serif; background: #f8fafc; }
  .topbar { background: #fff; border-bottom: 1.5px solid #e2e8f0; padding: 10px 20px; font-size: 13px; color: #64748b; }
  .topbar a { color: #334155; text-decoration: none; font-weight: 600; }
  #root { max-width: 960px; margin: 0 auto; padding: 16px; }
</style>
</head>
<body>
<div class="topbar"><a href="index.html">← nf-bioimage-spec</a> / Module categories</div>
<div id="root"></div>
<script type="text/babel">
CATEOF

# We need to inline the React component. Let's read it from the variant table
# Since we can't read the artifact directly, we embed it here:
cat >> docs/site/categories.html << 'REACTEOF'
const { useState } = React;

/* ══ DATA ══ */
const categories=[{id:"ImgProc",category:"Image Processing",task:"Denoising, deconvolution, flat-field correction, filtering",source:"custom",variants:[{storage:"monolithic",output:"image",parallelism:"external",userProfile:"enduser",gpu:"optional",model:"model_bundled",ecosystem:"python",ioStrategy:"new_file",dimHandling:"per_channel_slice",nfInput:'tuple val(meta), path(image)',nfOutput:'tuple val(meta), path("*_processed.{tif,tiff,png}"), emit: processed',params:"preset name",qc:"PSNR/SSIM summary CSV; before/after thumbnail",metaFields:["id","pixel_size_xy","pixel_size_z","bit_depth","n_channels"],ioNote:"New output file. Fully idempotent, -resume safe.",note:"Per-FOV/tile. Nextflow scatters images. Model weights bundled in container."},{storage:"monolithic",output:"image",parallelism:"external",userProfile:"developer",gpu:"optional",model:"model_input",ecosystem:"python",ioStrategy:"new_file",dimHandling:"per_channel_slice",nfInput:'tuple val(meta), path(image), path(model_weights)',nfOutput:'tuple val(meta), path("*_processed.{tif,tiff,png}"), emit: processed',params:"model path, model config YAML, all hyperparameters",qc:"PSNR/SSIM summary CSV; before/after thumbnail; model metadata log",metaFields:["id","pixel_size_xy","pixel_size_z","bit_depth","n_channels"],ioNote:"New output file. Fully idempotent.",note:"Per-FOV/tile. Model weights as input channel."},{storage:"chunked",output:"image",parallelism:"internal",userProfile:"enduser",gpu:"optional",model:"model_bundled",ecosystem:"python",ioStrategy:"new_group_same_zarr",dimHandling:"full_stack",nfInput:'tuple val(meta), path(zarr_dir)',nfOutput:'tuple val(meta), path(zarr_dir), emit: processed',params:"preset name",qc:"PSNR/SSIM summary CSV; before/after thumbnail",metaFields:["id","pixel_size_xy","pixel_size_z","bit_depth","n_channels"],ioNote:"New array group in same zarr. Original arrays untouched.",note:"Tool writes new array group (e.g. /processed/)."},{storage:"chunked",output:"image",parallelism:"internal",userProfile:"developer",gpu:"optional",model:"model_input",ecosystem:"python",ioStrategy:"new_group_same_zarr",dimHandling:"full_stack",nfInput:'tuple val(meta), path(zarr_dir), path(model_weights)',nfOutput:'tuple val(meta), path(zarr_dir), emit: processed',params:"model path, model config, chunk overlap, all hyperparameters",qc:"PSNR/SSIM summary CSV; before/after thumbnail; model metadata log",metaFields:["id","pixel_size_xy","pixel_size_z","bit_depth","n_channels"],ioNote:"New array group in same zarr. Original arrays untouched.",note:"Tool writes new array group. Model weights as input."}]},{id:"ObjSeg",category:"Object Segmentation",task:"Delineate individual objects as distinct labelled regions",source:"BIAFLOWS",variants:[{storage:"monolithic",output:"mask",parallelism:"external",userProfile:"enduser",gpu:"optional",model:"model_bundled",ecosystem:"python",ioStrategy:"new_file",dimHandling:"per_channel_slice",nfInput:'tuple val(meta), path(image)',nfOutput:'tuple val(meta), path("*_labels.{tif,tiff}"), emit: labels',params:"model name, diameter",qc:"Object count; mean area; segmentation overlay PNG; DICE if GT",metaFields:["id","pixel_size_xy","pixel_size_z","n_channels","channel_names"],ioNote:"New output file. Fully idempotent.",note:"Label image per FOV. Bundled model."},{storage:"monolithic",output:"mask",parallelism:"external",userProfile:"developer",gpu:"optional",model:"model_input",ecosystem:"python",ioStrategy:"new_file",dimHandling:"per_channel_slice",nfInput:'tuple val(meta), path(image), path(model_weights)',nfOutput:'tuple val(meta), path("*_labels.{tif,tiff}"), emit: labels',params:"model path, config, diameter, flow_threshold, cellprob_threshold, all",qc:"Object count; mean area; overlay PNG; DICE if GT; model metadata log",metaFields:["id","pixel_size_xy","pixel_size_z","n_channels","channel_names"],ioNote:"New output file. Fully idempotent.",note:"Custom model weights as input channel."},{storage:"monolithic",output:"vector",parallelism:"external",userProfile:"enduser",gpu:"optional",model:"model_bundled",ecosystem:"python",ioStrategy:"new_file",dimHandling:"per_channel_slice",nfInput:'tuple val(meta), path(image)',nfOutput:'tuple val(meta), path("*_labels.{geojson,wkt}"), emit: polygons',params:"model name, diameter, simplify tolerance",qc:"Object count; polygon overlay PNG",metaFields:["id","pixel_size_xy","n_channels","channel_names"],ioNote:"New output file. Fully idempotent.",note:"Polygons per FOV for QuPath/Cytomine."},{storage:"monolithic",output:"vector",parallelism:"external",userProfile:"developer",gpu:"optional",model:"model_input",ecosystem:"python",ioStrategy:"new_file",dimHandling:"per_channel_slice",nfInput:'tuple val(meta), path(image), path(model_weights)',nfOutput:'tuple val(meta), path("*_labels.{geojson,wkt}"), emit: polygons',params:"model path, all params, simplify tolerance",qc:"Object count; overlay PNG; model metadata log",metaFields:["id","pixel_size_xy","n_channels","channel_names"],ioNote:"New output file. Fully idempotent.",note:"Custom model. Vector output."},{storage:"chunked",output:"mask",parallelism:"internal",userProfile:"enduser",gpu:"optional",model:"model_bundled",ecosystem:"python",ioStrategy:"new_zarr_symlink_labels",dimHandling:"full_stack",nfInput:'tuple val(meta), path(zarr_dir)',nfOutput:'tuple val(meta), path("${meta.id}_seg.zarr"), emit: labels',params:"model name, diameter",qc:"Object count; segmentation overlay PNG",metaFields:["id","pixel_size_xy","pixel_size_z","n_channels","channel_names"],ioNote:"New zarr: symlinks to input + new labels/ group. Idempotent.",note:"New zarr with symlinks + labels/. Bundled model."},{storage:"chunked",output:"mask",parallelism:"internal",userProfile:"developer",gpu:"optional",model:"model_input",ecosystem:"python",ioStrategy:"new_zarr_symlink_labels",dimHandling:"full_stack",nfInput:'tuple val(meta), path(zarr_dir), path(model_weights)',nfOutput:'tuple val(meta), path("${meta.id}_seg.zarr"), emit: labels',params:"model path, config, chunk overlap, all params",qc:"Object count; overlay PNG; model metadata log",metaFields:["id","pixel_size_xy","pixel_size_z","n_channels","channel_names"],ioNote:"New zarr: symlinks to input + new labels/ group. Idempotent.",note:"Custom model weights. Full param control."}]},{id:"PixCla",category:"Pixel / Voxel Classification",task:"Assign each pixel to a semantic class",source:"BIAFLOWS",variants:[{storage:"monolithic",output:"mask",parallelism:"external",userProfile:"enduser",gpu:"optional",model:"model_bundled",ecosystem:"python",ioStrategy:"new_file",dimHandling:"per_channel_slice",nfInput:'tuple val(meta), path(image)',nfOutput:'tuple val(meta), path("*_class.{tif,tiff}"), emit: classes',params:"model name, class names",qc:"Class distribution histogram; overlay PNG",metaFields:["id","pixel_size_xy","pixel_size_z","n_channels"],ioNote:"New output file.",note:"Semantic mask per FOV. Bundled model."},{storage:"monolithic",output:"mask",parallelism:"external",userProfile:"developer",gpu:"optional",model:"model_input",ecosystem:"python",ioStrategy:"new_file",dimHandling:"per_channel_slice",nfInput:'tuple val(meta), path(image), path(model_weights)',nfOutput:'tuple val(meta), path("*_class.{tif,tiff}"), emit: classes',params:"model path, config, class names, threshold, all",qc:"Class histogram; overlay PNG; model metadata log",metaFields:["id","pixel_size_xy","pixel_size_z","n_channels"],ioNote:"New output file.",note:"Custom model. All params."},{storage:"chunked",output:"mask",parallelism:"internal",userProfile:"enduser",gpu:"optional",model:"model_bundled",ecosystem:"python",ioStrategy:"new_zarr_symlink_labels",dimHandling:"full_stack",nfInput:'tuple val(meta), path(zarr_dir)',nfOutput:'tuple val(meta), path("${meta.id}_class.zarr"), emit: classes',params:"model name, class names",qc:"Class distribution histogram; overlay PNG",metaFields:["id","pixel_size_xy","pixel_size_z","n_channels"],ioNote:"New zarr: symlinks + labels/. Idempotent.",note:"Per-chunk classification."},{storage:"chunked",output:"mask",parallelism:"internal",userProfile:"developer",gpu:"optional",model:"model_input",ecosystem:"python",ioStrategy:"new_zarr_symlink_labels",dimHandling:"full_stack",nfInput:'tuple val(meta), path(zarr_dir), path(model_weights)',nfOutput:'tuple val(meta), path("${meta.id}_class.zarr"), emit: classes',params:"model path, config, chunk overlap, all",qc:"Class histogram; overlay PNG; model metadata log",metaFields:["id","pixel_size_xy","pixel_size_z","n_channels"],ioNote:"New zarr: symlinks + labels/. Idempotent.",note:"Custom model. Full params."}]},{id:"ObjDet",category:"Spot / Object Detection",task:"Detect and localise objects",source:"BIAFLOWS",variants:[{storage:"monolithic",output:"points",parallelism:"external",userProfile:"enduser",gpu:"optional",model:"model_bundled",ecosystem:"python",ioStrategy:"new_file",dimHandling:"per_channel_slice",nfInput:'tuple val(meta), path(image)',nfOutput:'tuple val(meta), path("*_detections.{csv,tif}"), emit: detections',params:"detector type, spot size",qc:"Detection count; overlay PNG",metaFields:["id","pixel_size_xy","pixel_size_z","n_channels"],ioNote:"New output file.",note:"Point list or binary mask per FOV."},{storage:"chunked",output:"tabular",parallelism:"internal",userProfile:"enduser",gpu:"optional",model:"model_bundled",ecosystem:"python",ioStrategy:"read_only_new_file",dimHandling:"full_stack",nfInput:'tuple val(meta), path(zarr_dir)',nfOutput:'tuple val(meta), path("*_detections.csv"), emit: detections',params:"detector type, spot size",qc:"Detection count; spatial density map",metaFields:["id","pixel_size_xy","pixel_size_z","n_channels"],ioNote:"Reads zarr unchanged, writes CSV.",note:"Iterates chunks, deduplicates at boundaries."}]},{id:"SptCnt",category:"Spot / Object Counting",task:"Estimate the number of objects",source:"BIAFLOWS",variants:[{storage:"monolithic",output:"scalar",parallelism:"external",userProfile:"enduser",gpu:"optional",model:"model_bundled",ecosystem:"python",ioStrategy:"new_file",dimHandling:"per_channel_slice",nfInput:'tuple val(meta), path(image)',nfOutput:'tuple val(meta), path("*_counts.csv"), emit: counts',params:"counting method, object size",qc:"Count per FOV",metaFields:["id","pixel_size_xy","n_channels"],ioNote:"New output file.",note:"Count per FOV."}]},{id:"LndDet",category:"Landmark Detection",task:"Estimate position of feature points",source:"BIAFLOWS",variants:[{storage:"monolithic",output:"classmask",parallelism:"external",userProfile:"enduser",gpu:"optional",model:"model_bundled",ecosystem:"python",ioStrategy:"new_file",dimHandling:"per_channel_slice",nfInput:'tuple val(meta), path(image)',nfOutput:'tuple val(meta), path("*_landmarks.{csv,tif}"), emit: landmarks',params:"model name, n_landmarks",qc:"Landmark count; MRE if GT; overlay PNG",metaFields:["id","pixel_size_xy","n_channels","n_landmarks"],ioNote:"New output file.",note:"Coordinates or class mask per FOV."}]},{id:"TreTrc",category:"Filament / Tree Tracing",task:"Estimate medial axis of filament tree networks",source:"BIAFLOWS",variants:[{storage:"monolithic",output:"swc",parallelism:"internal",userProfile:"enduser",gpu:"none",model:"none",ecosystem:"java_fiji",ioStrategy:"new_file",dimHandling:"full_volume",nfInput:'tuple val(meta), path(image)',nfOutput:'tuple val(meta), path("*_trace.swc"), emit: traces',params:"tracing method, seed strategy",qc:"Branch count; total length; overlay",metaFields:["id","pixel_size_xy","pixel_size_z"],ioNote:"New output file.",note:"Global connectivity required. Single process."}]},{id:"LooTrc",category:"Filament Network Tracing",task:"Estimate medial axis of filament networks with loops",source:"BIAFLOWS",variants:[{storage:"monolithic",output:"skeleton",parallelism:"internal",userProfile:"enduser",gpu:"none",model:"none",ecosystem:"java_fiji",ioStrategy:"new_file",dimHandling:"full_volume",nfInput:'tuple val(meta), path(image)',nfOutput:'tuple val(meta), path("*_skeleton.{tif,tiff}"), emit: skeleton',params:"skeletonisation method",qc:"Network stats; skeleton overlay",metaFields:["id","pixel_size_xy","pixel_size_z"],ioNote:"New output file.",note:"Global connectivity required."}]},{id:"PrtTrk",category:"Particle Tracking",task:"Estimate tracks followed by particles",source:"BIAFLOWS",variants:[{storage:"monolithic",output:"track",parallelism:"internal",userProfile:"enduser",gpu:"none",model:"none",ecosystem:"java_fiji",ioStrategy:"new_file",dimHandling:"full_timelapse",nfInput:"tuple val(meta), path(images, stageAs: 'frames/*')",nfOutput:'tuple val(meta), path("*_tracks.{csv,tif}"), emit: tracks',params:"max linking distance, max gap frames",qc:"Track count; mean displacement; overlay",metaFields:["id","pixel_size_xy","pixel_size_z","time_interval","n_timepoints"],ioNote:"New output file.",note:"Linking across frames requires temporal context."}]},{id:"ObjTrk",category:"Object Tracking",task:"Estimate tracks + segmentation masks with divisions",source:"BIAFLOWS",variants:[{storage:"monolithic",output:"track+div",parallelism:"internal",userProfile:"enduser",gpu:"optional",model:"model_bundled",ecosystem:"python",ioStrategy:"new_file",dimHandling:"full_timelapse",nfInput:"tuple val(meta), path(images, stageAs: 'frames/*')",nfOutput:'tuple val(meta), path("*_tracks/"), emit: tracks',params:"model name / tracker type",qc:"Track count; division count; SEG/TRA if GT",metaFields:["id","pixel_size_xy","pixel_size_z","time_interval","n_timepoints","n_channels"],ioNote:"New output directory.",note:"CTC format output."}]},{id:"Stitch",category:"Stitching / Registration",task:"Align and merge tiles or time-points",source:"custom",variants:[{storage:"monolithic",output:"image",parallelism:"internal",userProfile:"enduser",gpu:"none",model:"none",ecosystem:"java_fiji",ioStrategy:"new_file",dimHandling:"multi_tile",nfInput:"tuple val(meta), path(images, stageAs: 'tiles/*')",nfOutput:'tuple val(meta), path("*_stitched.{tif,ome.tif}"), emit: stitched',params:"fusion method",qc:"Registration error summary",metaFields:["id","pixel_size_xy","pixel_size_z","tile_layout","overlap_pct"],ioNote:"New output file.",note:"Tool must see all tiles."},{storage:"chunked",output:"image",parallelism:"internal",userProfile:"enduser",gpu:"none",model:"none",ecosystem:"java_fiji",ioStrategy:"new_zarr_symlink_meta",dimHandling:"multi_tile",nfInput:'tuple val(meta), path(zarr_dir)',nfOutput:'tuple val(meta), path("${meta.id}_stitched.zarr"), emit: stitched',params:"fusion method",qc:"Registration error summary",metaFields:["id","pixel_size_xy","pixel_size_z","tile_layout","overlap_pct"],ioNote:"New zarr with rewritten metadata + symlinked chunks.",note:"New zarr with rewritten transforms."}]},{id:"FeatExt",category:"Feature Extraction",task:"Measure morphological, intensity, or texture features",source:"custom",variants:[{storage:"monolithic",output:"tabular",parallelism:"external",userProfile:"enduser",gpu:"none",model:"none",ecosystem:"python",ioStrategy:"new_file",dimHandling:"per_channel_slice",nfInput:'tuple val(meta), path(image), path(labels)',nfOutput:'tuple val(meta), path("*_features.csv"), emit: features',params:"feature set name",qc:"Feature summary stats; correlation matrix",metaFields:["id","pixel_size_xy","pixel_size_z","n_channels","channel_names"],ioNote:"New output file.",note:"Per-FOV measurement."},{storage:"chunked",output:"tabular",parallelism:"internal",userProfile:"enduser",gpu:"none",model:"none",ecosystem:"python",ioStrategy:"read_only_new_file",dimHandling:"full_stack",nfInput:'tuple val(meta), path(zarr_dir)',nfOutput:'tuple val(meta), path("*_features.csv"), emit: features',params:"feature set name",qc:"Feature summary stats",metaFields:["id","pixel_size_xy","pixel_size_z","n_channels","channel_names"],ioNote:"Reads zarr unchanged, writes CSV.",note:"Reads co-aligned intensity + label chunks."}]},{id:"Raster",category:"Rasterisation",task:"Convert vector annotations to raster label masks",source:"custom",variants:[{storage:"monolithic",output:"mask",parallelism:"external",userProfile:"enduser",gpu:"none",model:"none",ecosystem:"python",ioStrategy:"new_file",dimHandling:"single_plane",nfInput:'tuple val(meta), path(geojson), val(image_shape)',nfOutput:'tuple val(meta), path("*_labels.tif"), emit: labels',params:"—",qc:"Label count; overlay PNG",metaFields:["id","pixel_size_xy","image_width","image_height"],ioNote:"New output file.",note:"One label TIFF per vector file."},{storage:"chunked",output:"mask",parallelism:"internal",userProfile:"enduser",gpu:"none",model:"none",ecosystem:"python",ioStrategy:"new_zarr_symlink_labels",dimHandling:"single_plane",nfInput:'tuple val(meta), path(geojson), path(zarr_dir)',nfOutput:'tuple val(meta), path("${meta.id}_raster.zarr"), emit: labels',params:"—",qc:"Label count",metaFields:["id","pixel_size_xy"],ioNote:"New zarr: symlinks + labels/.",note:"Rasterise directly into zarr/labels/."}]},{id:"Seg2Vec",category:"Segmentation → Vector",task:"Convert segmentation masks to vector format",source:"custom",variants:[{storage:"monolithic",output:"vector",parallelism:"external",userProfile:"enduser",gpu:"none",model:"none",ecosystem:"python",ioStrategy:"new_file",dimHandling:"single_plane",nfInput:'tuple val(meta), path(labels)',nfOutput:'tuple val(meta), path("*_polygons.geojson"), emit: polygons',params:"simplify tolerance",qc:"Polygon count; vertex count stats",metaFields:["id","pixel_size_xy"],ioNote:"New output file.",note:"Contour tracing per FOV."},{storage:"chunked",output:"vector",parallelism:"internal",userProfile:"enduser",gpu:"none",model:"none",ecosystem:"python",ioStrategy:"read_only_new_file",dimHandling:"single_plane",nfInput:'tuple val(meta), path(zarr_dir)',nfOutput:'tuple val(meta), path("*_polygons.geojson"), emit: polygons',params:"simplify tolerance",qc:"Polygon count; vertex count stats",metaFields:["id","pixel_size_xy"],ioNote:"Reads zarr unchanged, writes GeoJSON.",note:"Reads label chunks, merges at boundaries."}]}];

/* ══ STYLES ══ */
const storageSt={monolithic:{color:"#b91c1c",bg:"#fef2f2",border:"#fca5a5",label:"Monolithic"},chunked:{color:"#047857",bg:"#ecfdf5",border:"#6ee7b7",label:"Chunked"}};
const parallelSt={external:{color:"#1d4ed8",bg:"#eff6ff",label:"External (NF)",icon:"⇉"},internal:{color:"#c2410c",bg:"#fff7ed",label:"Internal",icon:"⟳"}};
const outputSt={image:"🖼 Image",mask:"🏷 Mask",vector:"📐 Vector",tabular:"📊 Table",scalar:"# Scalar",skeleton:"🦴 Skeleton",swc:"🌳 SWC",track:"〰 Tracks","track+div":"〰÷ Tracks+Div",points:"· Points",classmask:"◎ ClassMask"};
const gpuSt={none:{label:"CPU only",color:"#475569",bg:"#f1f5f9"},optional:{label:"GPU optional",color:"#b45309",bg:"#fffbeb"},required:{label:"GPU required",color:"#dc2626",bg:"#fef2f2"}};
const modelSt={none:{label:"No model",color:"#475569",bg:"#f1f5f9"},model_bundled:{label:"Model in container",color:"#7c3aed",bg:"#f5f3ff"},model_input:{label:"Model as input",color:"#0369a1",bg:"#f0f9ff"}};
const ecosystemSt={python:{label:"Python",color:"#2563eb",bg:"#eff6ff"},java_fiji:{label:"Java/Fiji",color:"#b45309",bg:"#fffbeb"}};
const ioStrategySt={new_file:{label:"New file",color:"#166534",bg:"#f0fdf4",icon:"📄"},read_only_new_file:{label:"Read-only zarr → new file",color:"#166534",bg:"#f0fdf4",icon:"📄"},new_group_same_zarr:{label:"New group in same zarr",color:"#b45309",bg:"#fffbeb",icon:"📁+"},new_zarr_symlink_labels:{label:"New zarr (symlinks + labels/)",color:"#7c3aed",bg:"#f5f3ff",icon:"🔗🏷"},new_zarr_symlink_meta:{label:"New zarr (symlinks + metadata)",color:"#0369a1",bg:"#f0f9ff",icon:"🔗📋"}};
const userProfileSt={enduser:{label:"👤 End-user",color:"#0d9488",bg:"#f0fdfa",border:"#99f6e4"},developer:{label:"🛠 Developer",color:"#7c3aed",bg:"#f5f3ff",border:"#c4b5fd"}};
const dimSt={single_plane:"Single 2D plane",per_channel_slice:"Per channel/slice",full_volume:"Full 3D volume",full_stack:"Full TCZYX stack",full_timelapse:"Full time-lapse",multi_tile:"Multi-tile / multi-FOV"};
const sourceSt={custom:{bg:"#eef2ff",border:"#a5b4fc",badge:"#4f46e5",label:"Custom"},BIAFLOWS:{bg:"#ecfdf5",border:"#6ee7b7",badge:"#059669",label:"BIAFLOWS"}};

function Badge({label,color,bg}){return React.createElement("span",{style:{fontSize:10,fontWeight:600,padding:"2px 7px",borderRadius:5,background:bg,color,border:`1px solid ${color}`,whiteSpace:"nowrap",lineHeight:"18px"}},label)}
function Field({label,children,wide}){return React.createElement("div",{style:{background:"#f8fafc",borderRadius:6,padding:"7px 10px",gridColumn:wide?"1 / -1":undefined}},React.createElement("div",{style:{fontSize:10,fontWeight:700,color:"#64748b",textTransform:"uppercase",letterSpacing:0.5,marginBottom:3}},label),React.createElement("div",{style:{fontSize:12,color:"#1e293b",lineHeight:1.5}},children))}

function App(){
  const[expanded,setExpanded]=useState(null);
  const[filterSrc,setFilterSrc]=useState("all");
  const[filterProfile,setFilterProfile]=useState("all");
  const filtered=categories.filter(c=>filterSrc==="all"||c.source===filterSrc).map(c=>({...c,variants:filterProfile==="all"?c.variants:c.variants.filter(v=>v.userProfile===filterProfile)})).filter(c=>c.variants.length>0);
  const totalVariants=categories.reduce((s,c)=>s+c.variants.length,0);

  const e=React.createElement;
  return e("div",{style:{fontFamily:"system-ui, -apple-system, sans-serif",color:"#1e293b",padding:"16px",lineHeight:1.5}},
    e("h2",{style:{fontSize:20,fontWeight:700,margin:"0 0 2px",color:"#0f172a"}},"Image Analysis Module Types"),
    e("p",{style:{fontSize:13,color:"#475569",margin:"0 0 4px"}},categories.length," categories → ",e("strong",null,totalVariants," module variants")),
    e("p",{style:{fontSize:12,color:"#64748b",margin:"0 0 14px"}},e("strong",null,"Axes:")," Storage × Output × Parallelism × User profile"),

    e("div",{style:{display:"flex",gap:16,marginBottom:14,flexWrap:"wrap"}},
      e("div",{style:{display:"flex",gap:6,alignItems:"center"}},
        e("span",{style:{fontSize:11,fontWeight:600,color:"#64748b"}},"Source:"),
        [{key:"all",label:"All"},{key:"custom",label:"Custom"},{key:"BIAFLOWS",label:"BIAFLOWS"}].map(f=>
          e("button",{key:f.key,onClick:()=>setFilterSrc(f.key),style:{padding:"4px 12px",borderRadius:16,fontSize:11,cursor:"pointer",fontWeight:filterSrc===f.key?600:500,border:filterSrc===f.key?"2px solid #334155":"1.5px solid #cbd5e1",background:filterSrc===f.key?"#334155":"#fff",color:filterSrc===f.key?"#fff":"#334155"}},f.label))),
      e("div",{style:{display:"flex",gap:6,alignItems:"center"}},
        e("span",{style:{fontSize:11,fontWeight:600,color:"#64748b"}},"Profile:"),
        [{key:"all",label:"All"},{key:"enduser",label:"👤 End-user"},{key:"developer",label:"🛠 Developer"}].map(f=>
          e("button",{key:f.key,onClick:()=>setFilterProfile(f.key),style:{padding:"4px 12px",borderRadius:16,fontSize:11,cursor:"pointer",fontWeight:filterProfile===f.key?600:500,border:filterProfile===f.key?"2px solid #334155":"1.5px solid #cbd5e1",background:filterProfile===f.key?"#334155":"#fff",color:filterProfile===f.key?"#fff":"#334155"}},f.label)))),

    e("div",{style:{display:"flex",flexDirection:"column",gap:10}},
      filtered.map(cat=>{
        const src=sourceSt[cat.source];const isOpen=expanded===cat.id;
        return e("div",{key:cat.id,style:{background:src.bg,border:`1.5px solid ${src.border}`,borderRadius:10,overflow:"hidden"}},
          e("div",{onClick:()=>setExpanded(isOpen?null:cat.id),style:{padding:"12px 16px",cursor:"pointer"}},
            e("div",{style:{display:"flex",alignItems:"center",gap:8,flexWrap:"wrap"}},
              e("span",{style:{fontSize:10,fontWeight:700,padding:"2px 8px",borderRadius:10,background:src.badge,color:"#fff"}},src.label),
              e("span",{style:{fontWeight:700,fontSize:15,color:"#0f172a"}},cat.category),
              e("span",{style:{fontSize:12,color:"#64748b",fontFamily:"monospace"}},cat.id),
              e("span",{style:{marginLeft:"auto",display:"flex",gap:6,alignItems:"center"}},
                e("span",{style:{fontSize:12,color:"#475569",fontWeight:600}},cat.variants.length," variant",cat.variants.length>1?"s":""),
                e("span",{style:{fontSize:12,color:"#64748b",fontWeight:600}},isOpen?"▲":"▼"))),
            e("div",{style:{fontSize:13,color:"#334155",marginTop:4}},cat.task),
            e("div",{style:{display:"flex",gap:4,marginTop:8,flexWrap:"wrap"}},
              cat.variants.map((v,vi)=>{const st=storageSt[v.storage];const pl=parallelSt[v.parallelism];const up=userProfileSt[v.userProfile];
                return e("span",{key:vi,style:{display:"inline-flex",gap:3,alignItems:"center",fontSize:10,padding:"2px 7px",borderRadius:6,background:"#fff",border:`1px solid ${st.border}`,color:"#334155",fontWeight:500}},
                  e("span",{style:{color:up.color,fontWeight:700}},up.label.slice(0,2)),
                  e("span",{style:{color:st.color,fontWeight:700}},st.label),
                  e("span",{style:{color:"#94a3b8"}},"→"),
                  e("span",null,outputSt[v.output]||v.output),
                  e("span",{style:{color:pl.color,fontWeight:700}},pl.icon))}))),

          isOpen&&e("div",{style:{padding:"0 16px 16px"}},
            cat.variants.map((v,vi)=>{
              const st=storageSt[v.storage];const pl=parallelSt[v.parallelism];const gp=gpuSt[v.gpu];const ml=modelSt[v.model];const ec=ecosystemSt[v.ecosystem];const io=ioStrategySt[v.ioStrategy];const up=userProfileSt[v.userProfile];
              return e("div",{key:vi,style:{background:"#fff",border:`1.5px solid ${up.border}`,borderRadius:8,padding:"14px 16px",marginTop:vi>0?10:0,borderLeft:`5px solid ${up.color}`}},
                e("div",{style:{display:"flex",alignItems:"center",gap:8,marginBottom:10,padding:"6px 10px",borderRadius:6,background:up.bg,border:`1px solid ${up.border}`}},
                  e("span",{style:{fontSize:13,fontWeight:700,color:up.color}},up.label)),
                e("div",{style:{display:"flex",gap:5,alignItems:"center",marginBottom:10,flexWrap:"wrap"}},
                  e("span",{style:{fontSize:13,fontWeight:700,color:st.color}},st.label),
                  e("span",{style:{color:"#94a3b8",fontWeight:700}},"→"),
                  e("span",{style:{fontSize:13,fontWeight:600,color:"#334155"}},outputSt[v.output]||v.output),
                  e(Badge,{label:`${pl.icon} ${pl.label}`,color:pl.color,bg:pl.bg}),
                  e(Badge,{label:gp.label,color:gp.color,bg:gp.bg}),
                  e(Badge,{label:ml.label,color:ml.color,bg:ml.bg}),
                  e(Badge,{label:ec.label,color:ec.color,bg:ec.bg})),
                e("div",{style:{background:io.bg,border:`1.5px solid ${io.color}`,borderRadius:8,padding:"8px 12px",marginBottom:10}},
                  e("div",{style:{fontSize:10,fontWeight:700,color:io.color,textTransform:"uppercase",letterSpacing:0.5,marginBottom:3}},io.icon," I/O: ",io.label),
                  e("div",{style:{fontSize:11,color:"#334155",lineHeight:1.5}},v.ioNote)),
                e("div",{style:{display:"grid",gridTemplateColumns:"1fr 1fr",gap:8,marginBottom:10}},
                  e("div",{style:{background:"#f0fdf4",borderRadius:6,padding:"8px 10px",border:"1px solid #bbf7d0"}},
                    e("div",{style:{fontSize:10,fontWeight:700,color:"#166534",textTransform:"uppercase",marginBottom:4}},"NF Input"),
                    e("code",{style:{fontSize:11,color:"#14532d",fontFamily:"monospace",wordBreak:"break-all"}},v.nfInput)),
                  e("div",{style:{background:"#fefce8",borderRadius:6,padding:"8px 10px",border:"1px solid #fde68a"}},
                    e("div",{style:{fontSize:10,fontWeight:700,color:"#854d0e",textTransform:"uppercase",marginBottom:4}},"NF Output"),
                    e("code",{style:{fontSize:11,color:"#713f12",fontFamily:"monospace",wordBreak:"break-all"}},v.nfOutput))),
                e("div",{style:{display:"grid",gridTemplateColumns:"repeat(auto-fill, minmax(200px, 1fr))",gap:8}},
                  e(Field,{label:"Dimensionality"},dimSt[v.dimHandling]||v.dimHandling),
                  e(Field,{label:"Params"},v.params),
                  e(Field,{label:"QC outputs"},v.qc),
                  e(Field,{label:"Meta fields",wide:true},e("code",{style:{fontSize:11,fontFamily:"monospace"}},
                    "[",v.metaFields.map(f=>`"${f}"`).join(", "),"]"))),
                e("div",{style:{fontSize:12,color:"#475569",marginTop:10,fontStyle:"italic"}},v.note))})))}))));
}

ReactDOM.render(React.createElement(App), document.getElementById('root'));
REACTEOF

cat >> docs/site/categories.html << 'ENDEOF'
</script>
</body>
</html>
ENDEOF
echo "✓ docs/site/categories.html"

# ── docs/site/templates.html — Template generator (loads from schemas) ──
cat > docs/site/templates.html << 'TMPLEOF'
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>Template generator — nf-bioimage-spec</title>
<script src="https://cdnjs.cloudflare.com/ajax/libs/react/18.2.0/umd/react.production.min.js"></script>
<script src="https://cdnjs.cloudflare.com/ajax/libs/react-dom/18.2.0/umd/react-dom.production.min.js"></script>
<script src="https://cdnjs.cloudflare.com/ajax/libs/babel-standalone/7.23.9/babel.min.js"></script>
<style>
  * { box-sizing: border-box; margin: 0; padding: 0; }
  body { font-family: system-ui, -apple-system, sans-serif; background: #f8fafc; }
  .topbar { background: #fff; border-bottom: 1.5px solid #e2e8f0; padding: 10px 20px; font-size: 13px; color: #64748b; }
  .topbar a { color: #334155; text-decoration: none; font-weight: 600; }
  #root { max-width: 960px; margin: 0 auto; padding: 16px; }
  pre { background: #0f172a; color: #e2e8f0; padding: 12px; border-radius: 0 0 8px 8px; font-size: 11px; line-height: 1.6; overflow-x: auto; white-space: pre-wrap; word-break: break-word; }
  .tab-bar button { padding: 6px 14px; font-size: 11px; cursor: pointer; font-family: monospace; border: 1.5px solid #334155; border-radius: 6px 6px 0 0; }
  .tab-bar button.active { background: #0f172a; color: #e2e8f0; border-bottom: none; font-weight: 700; }
  .tab-bar button:not(.active) { background: #e2e8f0; color: #334155; }
  .code-header { display: flex; justify-content: space-between; align-items: center; background: #1e293b; color: #94a3b8; padding: 6px 12px; border-radius: 8px 8px 0 0; font-size: 11px; }
  .copy-btn { background: none; border: 1px solid #475569; border-radius: 4px; color: #94a3b8; font-size: 10px; padding: 2px 8px; cursor: pointer; }
</style>
</head>
<body>
<div class="topbar"><a href="index.html">← nf-bioimage-spec</a> / Template generator</div>
<div id="root"></div>
<script type="text/babel">
const { useState } = React;
const e = React.createElement;

/* Load schemas at build time — for GH Pages we inline the fetch from relative paths */
const STORAGE_ABBR={"monolithic":"Mono","chunked":"Chnk"};
const OUTPUT_ABBR={"image":"Img","mask":"Msk","vector":"Vec","tabular":"Tab","scalar":"Scl","skeleton":"Skl","swc":"SWC","track":"Trk","track+div":"TrkDiv","points":"Pts","classmask":"ClsMsk"};
const PARALLEL_ABBR={"external":"Ext","internal":"Int"};
const PROFILE_ABBR={"enduser":"EU","developer":"Dev"};
const CAT_NAMES={"ImgProc":"ImageProcessing","Stitch":"StitchingRegistration","ObjSeg":"ObjectSegmentation","PixCla":"PixelVoxelClassification","ObjDet":"SpotObjectDetection","SptCnt":"SpotObjectCounting","LndDet":"LandmarkDetection","TreTrc":"FilamentTreeTracing","LooTrc":"FilamentNetworkTracing","PrtTrk":"ParticleTracking","ObjTrk":"ObjectTracking","FeatExt":"FeatureExtraction","Raster":"Rasterisation","Seg2Vec":"SegmentationToVector"};
const OUTPUT_SUFFIX={"image":"_processed.tif","mask":"_labels.tif","vector":"_labels.geojson","tabular":"_features.csv","scalar":"_counts.csv","skeleton":"_skeleton.tif","swc":"_trace.swc","track":"_tracks.csv","track+div":"_tracks/","points":"_detections.csv","classmask":"_landmarks.csv"};

function getNames(catId,v){
  const full=`${CAT_NAMES[catId]}_${{"monolithic":"Monolithic","chunked":"Chunked"}[v.storage]}_${OUTPUT_ABBR[v.output]==="Img"?"Image":OUTPUT_ABBR[v.output]}_${{"external":"External","internal":"Internal"}[v.parallelism]}_${{"enduser":"EndUser","developer":"Developer"}[v.user_profile]}`;
  const abbr=`${catId}_${STORAGE_ABBR[v.storage]}_${OUTPUT_ABBR[v.output]}_${PARALLEL_ABBR[v.parallelism]}_${PROFILE_ABBR[v.user_profile]}`;
  return{full,abbr,path:`templates/${v.storage}/${v.user_profile}/${catId.toLowerCase()}/`,process:abbr.toUpperCase()};
}

function genMainNf(cat,v,names){
  const tool=cat.id.toLowerCase();
  const label=v.gpu==="optional"?"process_medium":v.gpu==="required"?"process_gpu":v.parallelism==="internal"?"process_high":"process_medium";
  const vcmd=v.ecosystem==="python"?`python -m ${tool} --version 2>&1 | sed 's/.*//g'`:`fiji --headless --eval 'println(System.getProperty("fiji.version"))'`;
  const pkg=v.ecosystem==="python"?tool:`fiji-${tool}`;
  return `// Full name:    ${names.full}
// Abbreviation: ${names.abbr}

process ${names.process} {
    tag "$meta.id"
    label '${label}'

    conda "bioconda::${pkg}=1.0.0"
    container "${ 'workflow.containerEngine' }..."

    input:
    ${v.nf_input}

    output:
    ${v.nf_output}
    tuple val("\${task.process}"), val('${tool}'), eval('${vcmd}'), emit: versions_${tool}, topic: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    def args = task.ext.args ?: ''
    def prefix = task.ext.prefix ?: "\${meta.id}"
    """
    python -m ${tool} \\\\
        --input ${v.storage==="chunked"?"\\${zarr_dir}":"\\${image}"} \\\\${v.model==="model_input"?"\n        --model \\${model_weights} \\\\":""}
        --output \\${prefix}${OUTPUT_SUFFIX[v.output]||"_output.txt"} \\\\
        \\$args
    """

    stub:
    def prefix = task.ext.prefix ?: "\${meta.id}"
    """
    touch \\${prefix}${OUTPUT_SUFFIX[v.output]||"_output.txt"}
    """
}`;
}

function genMetaYml(cat,v,names){
  const tool=cat.id.toLowerCase();
  return `# Full name:    ${names.full}
# Abbreviation: ${names.abbr}

name: "${names.abbr.toLowerCase()}"
description: |
  ${cat.task}
  Storage: ${v.storage} | Profile: ${v.user_profile}
keywords: [bioimage, ${tool}, ${v.storage}, ${v.output}]
tools:
  - "${tool}":
      description: "${cat.task}"
      licence: ["MIT"]
input:
  - meta:
      type: map
      description: Sample metadata map
${v.storage==="chunked"?`  - zarr_dir:
      type: directory
      pattern: "*.zarr"`:`  - image:
      type: file
      pattern: "*.{tif,tiff,png}"`}${v.model==="model_input"?`
  - model_weights:
      type: file
      pattern: "*.{pth,h5,onnx,pt}"`:""}
topics:
  versions:
    - - "\${task.process}": {type: string}
      - "${tool}": {type: string}
      - eval: {type: eval}`;
}

function genTest(cat,v,names){
  return `// ${names.abbr}
nextflow_process {
    name "Test ${names.process}"
    script "../main.nf"
    process "${names.process}"

    test("Should run ${cat.id} ${v.storage} ${v.user_profile}") {
        when {
            process {
                """
                input[0] = [
                    [id: 'test', pixel_size_xy: 0.65],
                    file(params.test_data['${v.storage==="chunked"?"zarr":"image"}'], checkIfExists: true)${v.model==="model_input"?`,
                    file(params.test_data['model'], checkIfExists: true)`:""}
                ]
                """
            }
        }
        then {
            assertAll(
                { assert process.success },
                { assert snapshot(process.out).match() },
                { assert process.out.findAll { key, val -> key.startsWith('versions') } }
            )
        }
    }
}`;
}

function genModulesConfig(cat,v,names){
  const paramLines=(v.params||"").split(",").map(p=>`            // ${p.trim()}`).join("\n");
  return `// ${names.abbr}
process {
    withName: '${names.process}' {
        ext.args = [
${paramLines}
        ].join(' ')
        publishDir = [
            path: { "\${params.outdir}/${cat.id.toLowerCase()}" },
            mode: params.publish_dir_mode,
            saveAs: { fn -> fn == 'versions.yml' ? null : fn }
        ]
    }
}`;
}

function App(){
  const[cats,setCats]=useState(null);
  const[variants,setVariants]=useState(null);
  const[selCat,setSelCat]=useState(null);
  const[selVar,setSelVar]=useState(null);
  const[tab,setTab]=useState("main.nf");
  const[copied,setCopied]=useState(false);

  React.useEffect(()=>{
    fetch("../schemas/categories.json").then(r=>r.json()).then(setCats).catch(()=>{});
    fetch("../schemas/variants.json").then(r=>r.json()).then(setVariants).catch(()=>{});
  },[]);

  if(!cats||!variants) return e("div",{style:{padding:40,textAlign:"center",color:"#64748b"}},"Loading schemas...");

  const catMap=Object.fromEntries(cats.map(c=>[c.id,c]));
  const catIds=[...new Set(variants.map(v=>v.category_id))];
  const cat=catMap[selCat];
  const catVariants=variants.filter(v=>v.category_id===selCat);
  const variant=catVariants[selVar];
  const names=cat&&variant?getNames(cat.id,variant):null;

  const tabs=["main.nf","meta.yml","test/main.nf.test","modules.config"];
  let code="";
  if(cat&&variant&&names){
    if(tab==="main.nf") code=genMainNf(cat,variant,names);
    else if(tab==="meta.yml") code=genMetaYml(cat,variant,names);
    else if(tab==="test/main.nf.test") code=genTest(cat,variant,names);
    else code=genModulesConfig(cat,variant,names);
  }

  return e("div",{style:{fontFamily:"system-ui",color:"#1e293b",padding:16,lineHeight:1.5}},
    e("h2",{style:{fontSize:20,fontWeight:700,margin:"0 0 4px"}},"nf-core Module Templates"),
    e("p",{style:{fontSize:13,color:"#475569",margin:"0 0 14px"}},"Select category → variant → browse generated files"),

    e("div",{style:{display:"flex",gap:6,flexWrap:"wrap",marginBottom:12}},
      catIds.map(id=>e("button",{key:id,onClick:()=>{setSelCat(id);setSelVar(null)},style:{padding:"5px 12px",borderRadius:8,fontSize:12,cursor:"pointer",border:selCat===id?"2px solid #1e293b":"1.5px solid #cbd5e1",background:selCat===id?"#1e293b":"#fff",color:selCat===id?"#fff":"#334155",fontWeight:selCat===id?700:500}},id))),

    cat&&e("div",{style:{marginBottom:14}},
      e("div",{style:{fontSize:12,fontWeight:600,color:"#64748b",marginBottom:6}},cat.category," — ",catVariants.length," variants:"),
      e("div",{style:{display:"flex",gap:6,flexWrap:"wrap"}},
        catVariants.map((v,vi)=>e("button",{key:vi,onClick:()=>{setSelVar(vi);setTab("main.nf")},style:{padding:"5px 12px",borderRadius:8,fontSize:11,cursor:"pointer",textAlign:"left",border:selVar===vi?"2px solid #334155":"1.5px solid #cbd5e1",background:selVar===vi?"#f0fdf4":"#fff",color:"#334155",fontWeight:selVar===vi?700:500}},
          e("div",null,v.user_profile==="enduser"?"👤":"🛠"," ",v.storage," → ",v.output),
          names&&selVar===vi&&e("div",{style:{fontSize:9,fontFamily:"monospace",color:"#64748b",marginTop:2}},getNames(cat.id,v).abbr))))),

    names&&e("div",null,
      e("div",{style:{background:"#f8fafc",border:"1.5px solid #e2e8f0",borderRadius:10,padding:"12px 14px",marginBottom:12}},
        e("div",{style:{display:"grid",gridTemplateColumns:"auto 1fr",gap:"4px 12px",fontSize:12}},
          e("span",{style:{fontWeight:700,color:"#64748b"}},"Full:"),e("code",{style:{fontFamily:"monospace",color:"#0f172a"}},names.full),
          e("span",{style:{fontWeight:700,color:"#64748b"}},"Abbr:"),e("code",{style:{fontFamily:"monospace",color:"#0f172a",fontWeight:700}},names.abbr),
          e("span",{style:{fontWeight:700,color:"#64748b"}},"Path:"),e("code",{style:{fontFamily:"monospace",color:"#475569",fontSize:11}},names.path),
          e("span",{style:{fontWeight:700,color:"#64748b"}},"Process:"),e("code",{style:{fontFamily:"monospace",color:"#475569",fontSize:11}},names.process))),

      e("div",{className:"tab-bar",style:{display:"flex",gap:2}},
        tabs.map(t=>e("button",{key:t,className:tab===t?"active":"",onClick:()=>setTab(t)},t))),

      e("div",null,
        e("div",{className:"code-header"},
          e("span",null,tab),
          e("button",{className:"copy-btn",onClick:()=>{navigator.clipboard.writeText(code);setCopied(true);setTimeout(()=>setCopied(false),2000)}},copied?"✓ Copied":"Copy")),
        e("pre",null,code))),

    !selCat&&e("div",{style:{padding:40,textAlign:"center",color:"#94a3b8"}},"↑ Select a category"),
    selCat&&selVar===null&&e("div",{style:{padding:20,textAlign:"center",color:"#94a3b8"}},"↑ Select a variant"));
}

ReactDOM.render(React.createElement(App), document.getElementById('root'));
</script>
</body>
</html>
TMPLEOF
echo "✓ docs/site/templates.html"

echo ""
echo "═══════════════════════════════════════════"
echo "✓ GitHub Pages site created in docs/site/"
echo ""
echo "Next steps:"
echo "  cd /Users/tl10/Documents/nf-bioimage-spec"
echo "  git add docs/site/"
echo '  git commit -m "docs: add interactive GitHub Pages site"'
echo "  git push origin main"
echo ""
echo "Then enable GitHub Pages:"
echo "  1. Go to https://github.com/BioinfoTongLI/nf-bioimage-spec/settings/pages"
echo "  2. Source: Deploy from a branch"
echo "  3. Branch: main"
echo "  4. Folder: /docs/site"
echo "  5. Save"
echo ""
echo "Your site will be at:"
echo "  https://bioinfotongli.github.io/nf-bioimage-spec/"
echo "═══════════════════════════════════════════"
