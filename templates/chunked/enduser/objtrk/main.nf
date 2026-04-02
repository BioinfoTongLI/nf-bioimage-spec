// Full name:    ObjectTracking_Chunked_TracksWithDivision_Internal_EndUser
// Abbreviation: ObjTrk_Chnk_TrkDiv_Int_EU

process OBJTRK_CHNK_TRKDIV_INT_EU {
    tag "$meta.id"
    label 'process_medium'

    conda "bioconda::objtrk=1.0.0"
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://depot.galaxyproject.org/singularity/objtrk:1.0.0--pyhdfd78af_0' :
        'biocontainers/objtrk:1.0.0--pyhdfd78af_0' }"

    input:
    tuple val(meta), path(zarr_dir)

    output:
    tuple val(meta), path("${meta.id}_tracked.zarr"), emit: labels
    tuple val(meta), path("*_division.txt"), emit: divisions
    tuple val("${task.process}"), val('objtrk'), eval('python -m objtrk --version 2>&1 | sed 's/.*//g''), emit: versions_objtrk, topic: versions

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
    
    python -m objtrk \\
        --input-zarr ${zarr_dir} \\
        --output-zarr ${out_zarr} \\
        $args
    """

    stub:
    def prefix = task.ext.prefix ?: "${meta.id}"
    """
    touch ${prefix}_tracks/
    """
}
