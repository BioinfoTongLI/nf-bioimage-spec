// Full name:    ParticleTracking_Chunked_Tracks_Internal_EndUser
// Abbreviation: PrtTrk_Chnk_Trk_Int_EU

process PRTTRK_CHNK_TRK_INT_EU {
    tag "$meta.id"
    label 'process_high'

    conda "bioconda::prttrk=1.0.0"
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://depot.galaxyproject.org/singularity/prttrk:1.0.0--pyhdfd78af_0' :
        'biocontainers/prttrk:1.0.0--pyhdfd78af_0' }"

    input:
    tuple val(meta), path(zarr_dir)

    output:
    tuple val(meta), path("*_tracks.csv"), emit: tracks
    tuple val("${task.process}"), val('prttrk'), eval('python -m prttrk --version 2>&1 | sed 's/.*//g''), emit: versions_prttrk, topic: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    def args = task.ext.args ?: ''
    def prefix = task.ext.prefix ?: "${meta.id}"
    """
    python -m prttrk \\
        --input-zarr ${zarr_dir} \\
        --output ${prefix}_tracks.csv \\
        $args
    """

    stub:
    def prefix = task.ext.prefix ?: "${meta.id}"
    """
    touch ${prefix}_tracks.csv
    """
}
