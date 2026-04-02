// Full name:    PixelVoxelClassification_Monolithic_LabelMask_External_EndUser
// Abbreviation: PixCla_Mono_Msk_Ext_EU

process PIXCLA_MONO_MSK_EXT_EU {
    tag "$meta.id"
    label 'process_medium'

    conda "bioconda::pixcla=1.0.0"
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://depot.galaxyproject.org/singularity/pixcla:1.0.0--pyhdfd78af_0' :
        'biocontainers/pixcla:1.0.0--pyhdfd78af_0' }"

    input:
    tuple val(meta), path(image)

    output:
    tuple val(meta), path("*_class.{tif,tiff}"), emit: classes
    tuple val("${task.process}"), val('pixcla'), eval('python -m pixcla --version 2>&1 | sed 's/.*//g''), emit: versions_pixcla, topic: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    def args = task.ext.args ?: ''
    def prefix = task.ext.prefix ?: "${meta.id}"
    """
    python -m pixcla \\
        --input $image \\
        --output ${prefix}_labels.tif \\
        $args
    """

    stub:
    def prefix = task.ext.prefix ?: "${meta.id}"
    """
    touch ${prefix}_labels.tif
    """
}
