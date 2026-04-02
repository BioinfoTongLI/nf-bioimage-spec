// Full name:    SpotObjectCounting_Chunked_Scalar_Internal_EndUser
// Abbreviation: SptCnt_Chnk_Scl_Int_EU

process SPTCNT_CHNK_SCL_INT_EU {
    tag "$meta.id"
    label 'process_medium'

    conda "bioconda::sptcnt=1.0.0"
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://depot.galaxyproject.org/singularity/sptcnt:1.0.0--pyhdfd78af_0' :
        'biocontainers/sptcnt:1.0.0--pyhdfd78af_0' }"

    input:
    tuple val(meta), path(zarr_dir)

    output:
    tuple val(meta), path("*_counts.csv"), emit: counts
    tuple val("${task.process}"), val('sptcnt'), eval('python -m sptcnt --version 2>&1 | sed 's/.*//g''), emit: versions_sptcnt, topic: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    def args = task.ext.args ?: ''
    def prefix = task.ext.prefix ?: "${meta.id}"
    """
    python -m sptcnt \\
        --input-zarr ${zarr_dir} \\
        --output ${prefix}_counts.csv \\
        $args
    """

    stub:
    def prefix = task.ext.prefix ?: "${meta.id}"
    """
    touch ${prefix}_counts.csv
    """
}
