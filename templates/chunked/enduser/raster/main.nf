// Full name:    Rasterisation_Chunked_LabelMask_Internal_EndUser
// Abbreviation: Raster_Chnk_Msk_Int_EU

process RASTER_CHNK_MSK_INT_EU {
    tag "$meta.id"
    label 'process_high'

    conda "bioconda::raster=1.0.0"
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://depot.galaxyproject.org/singularity/raster:1.0.0--pyhdfd78af_0' :
        'biocontainers/raster:1.0.0--pyhdfd78af_0' }"

    input:
    tuple val(meta), path(geojson), path(zarr_dir)

    output:
    tuple val(meta), path("${meta.id}_raster.zarr"), emit: labels
    tuple val("${task.process}"), val('raster'), eval('python -m raster --version 2>&1 | sed 's/.*//g''), emit: versions_raster, topic: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    def args = task.ext.args ?: ''
    def prefix = task.ext.prefix ?: "${meta.id}"
    def out_zarr = "${prefix}_out.zarr"
    """
    python -c "
    import os; from pathlib import Path
    src, dst = Path('${zarr_dir}'), Path('${out_zarr}')
    dst.mkdir(exist_ok=True)
    for item in src.iterdir():
        if item.name != 'labels': os.symlink(item.resolve(), dst / item.name)
    "
    
    python -m raster \\
        --input-zarr ${zarr_dir} \\
        --output-zarr ${out_zarr} \\
        $args
    """

    stub:
    def prefix = task.ext.prefix ?: "${meta.id}"
    """
    touch ${prefix}_labels.tif
    """
}
