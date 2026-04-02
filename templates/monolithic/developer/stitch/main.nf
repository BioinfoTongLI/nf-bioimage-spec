// Full name:    StitchingRegistration_Monolithic_Image_Internal_Developer
// Abbreviation: Stitch_Mono_Img_Int_Dev

process STITCH_MONO_IMG_INT_DEV {
    tag "$meta.id"
    label 'process_high'

    conda "bioconda::fiji-stitch=1.0.0"
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://depot.galaxyproject.org/singularity/fiji-stitch:1.0.0--pyhdfd78af_0' :
        'biocontainers/fiji-stitch:1.0.0--pyhdfd78af_0' }"

    input:
    tuple val(meta), path(images, stageAs: 'tiles/*')

    output:
    tuple val(meta), path("*_stitched.{tif,ome.tif}"), emit: stitched
    tuple val("${task.process}"), val('stitch'), eval('fiji --headless --eval 'println(System.getProperty("fiji.version"))' 2>&1 | tail -1'), emit: versions_stitch, topic: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    def args = task.ext.args ?: ''
    def prefix = task.ext.prefix ?: "${meta.id}"
    """
    fiji --headless --run stitch.groovy \\
        --input $image \\
        --output ${prefix}_processed.tif \\
        $args
    """

    stub:
    def prefix = task.ext.prefix ?: "${meta.id}"
    """
    touch ${prefix}_processed.tif
    """
}
