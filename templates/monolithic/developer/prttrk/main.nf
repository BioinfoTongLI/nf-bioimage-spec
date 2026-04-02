// Full name:    ParticleTracking_Monolithic_Tracks_Internal_Developer
// Abbreviation: PrtTrk_Mono_Trk_Int_Dev

process PRTTRK_MONO_TRK_INT_DEV {
    tag "$meta.id"
    label 'process_high'

    conda "bioconda::fiji-prttrk=1.0.0"
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://depot.galaxyproject.org/singularity/fiji-prttrk:1.0.0--pyhdfd78af_0' :
        'biocontainers/fiji-prttrk:1.0.0--pyhdfd78af_0' }"

    input:
    tuple val(meta), path(images, stageAs: 'frames/*')

    output:
    tuple val(meta), path("*_tracks.{csv,tif}"), emit: tracks
    tuple val("${task.process}"), val('prttrk'), eval('fiji --headless --eval 'println(System.getProperty("fiji.version"))' 2>&1 | tail -1'), emit: versions_prttrk, topic: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    def args = task.ext.args ?: ''
    def prefix = task.ext.prefix ?: "${meta.id}"
    """
    fiji --headless --run prttrk.groovy \\
        --input $image \\
        --output ${prefix}_tracks.csv \\
        $args
    """

    stub:
    def prefix = task.ext.prefix ?: "${meta.id}"
    """
    touch ${prefix}_tracks.csv
    """
}
