// Full name:    ImageProcessing_Monolithic_Image_External_EndUser
// Abbreviation: ImgProc_Mono_Img_Ext_EU

process IMGPROC_MONO_IMG_EXT_EU {
    tag "$meta.id"
    label 'process_medium'

    conda "bioconda::imgproc=1.0.0"
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://depot.galaxyproject.org/singularity/imgproc:1.0.0--pyhdfd78af_0' :
        'biocontainers/imgproc:1.0.0--pyhdfd78af_0' }"

    input:
    tuple val(meta), path(image)

    output:
    tuple val(meta), path("*_processed.{tif,tiff,png}"), emit: processed
    tuple val("${task.process}"), val('imgproc'), eval('python -m imgproc --version 2>&1 | sed 's/.*//g''), emit: versions_imgproc, topic: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    def args = task.ext.args ?: ''
    def prefix = task.ext.prefix ?: "${meta.id}"
    """
    python -m imgproc \\
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
