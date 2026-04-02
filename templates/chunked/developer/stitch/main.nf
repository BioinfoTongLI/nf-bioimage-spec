// Full name:    StitchingRegistration_Chunked_Image_Internal_Developer
// Abbreviation: Stitch_Chnk_Img_Int_Dev

process STITCH_CHNK_IMG_INT_DEV {
    tag "$meta.id"
    label 'process_high'

    conda "bioconda::fiji-stitch=1.0.0"
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://depot.galaxyproject.org/singularity/fiji-stitch:1.0.0--pyhdfd78af_0' :
        'biocontainers/fiji-stitch:1.0.0--pyhdfd78af_0' }"

    input:
    tuple val(meta), path(zarr_dir)

    output:
    tuple val(meta), path("${meta.id}_stitched.zarr"), emit: stitched
    tuple val("${task.process}"), val('stitch'), eval('fiji --headless --eval 'println(System.getProperty("fiji.version"))' 2>&1 | tail -1'), emit: versions_stitch, topic: versions

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
    
    python -m stitch \\
        --input-zarr ${zarr_dir} \\
        --output-zarr ${out_zarr} \\
        $args
    """

    stub:
    def prefix = task.ext.prefix ?: "${meta.id}"
    """
    touch ${prefix}_processed.tif
    """
}
