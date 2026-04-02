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
