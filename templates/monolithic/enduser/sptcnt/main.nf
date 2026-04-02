// Full name:    SpotObjectCounting_Monolithic_Scalar_External_EndUser
// Abbreviation: SptCnt_Mono_Scl_Ext_EU

process SPTCNT_MONO_SCL_EXT_EU {
    tag "$meta.id"
    label 'process_medium'

    conda "bioconda::sptcnt=1.0.0"
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://depot.galaxyproject.org/singularity/sptcnt:1.0.0--pyhdfd78af_0' :
        'biocontainers/sptcnt:1.0.0--pyhdfd78af_0' }"

    input:
    tuple val(meta), path(image)

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
        --input $image \\
        --output ${prefix}_counts.csv \\
        $args
    """

    stub:
    def prefix = task.ext.prefix ?: "${meta.id}"
    """
    touch ${prefix}_counts.csv
    """
}
