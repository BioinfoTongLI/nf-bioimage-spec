// Full name:    ObjectTracking_Monolithic_TracksWithDivision_Internal_EndUser
// Abbreviation: ObjTrk_Mono_TrkDiv_Int_EU

process OBJTRK_MONO_TRKDIV_INT_EU {
    tag "$meta.id"
    label 'process_medium'

    conda "bioconda::objtrk=1.0.0"
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://depot.galaxyproject.org/singularity/objtrk:1.0.0--pyhdfd78af_0' :
        'biocontainers/objtrk:1.0.0--pyhdfd78af_0' }"

    input:
    tuple val(meta), path(images, stageAs: 'frames/*')

    output:
    tuple val(meta), path("*_tracks/"), emit: tracks
    tuple val("${task.process}"), val('objtrk'), eval('python -m objtrk --version 2>&1 | sed 's/.*//g''), emit: versions_objtrk, topic: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    def args = task.ext.args ?: ''
    def prefix = task.ext.prefix ?: "${meta.id}"
    """
    python -m objtrk \\
        --input $image \\
        --output ${prefix}_tracks/ \\
        $args
    """

    stub:
    def prefix = task.ext.prefix ?: "${meta.id}"
    """
    touch ${prefix}_tracks/
    """
}
