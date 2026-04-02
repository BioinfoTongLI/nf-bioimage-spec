// Full name:    ObjectSegmentation_Chunked_LabelMask_Internal_Developer
// Abbreviation: ObjSeg_Chnk_Msk_Int_Dev

process OBJSEG_CHNK_MSK_INT_DEV {
    tag "$meta.id"
    label 'process_medium'

    conda "bioconda::objseg=1.0.0"
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://depot.galaxyproject.org/singularity/objseg:1.0.0--pyhdfd78af_0' :
        'biocontainers/objseg:1.0.0--pyhdfd78af_0' }"

    input:
    tuple val(meta), path(zarr_dir), path(model_weights)

    output:
    tuple val(meta), path("${meta.id}_seg.zarr"), emit: labels
    tuple val("${task.process}"), val('objseg'), eval('python -m objseg --version 2>&1 | sed 's/.*//g''), emit: versions_objseg, topic: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    def args = task.ext.args ?: ''
    def prefix = task.ext.prefix ?: "${meta.id}"
    def out_zarr = "${prefix}_seg.zarr"
    """
    python -c "
    import os; from pathlib import Path
    src, dst = Path('${zarr_dir}'), Path('${out_zarr}')
    dst.mkdir(exist_ok=True)
    for item in src.iterdir():
        if item.name != 'labels': os.symlink(item.resolve(), dst / item.name)
    "
    
    python -m objseg \\
        --input-zarr ${zarr_dir} \\
        --output-zarr ${out_zarr} \\
        --model ${model_weights} \\
        $args
    """

    stub:
    def prefix = task.ext.prefix ?: "${meta.id}"
    """
    touch ${prefix}_labels.tif
    """
}
