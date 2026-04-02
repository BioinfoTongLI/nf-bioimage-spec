// Full name:    Rasterisation_Monolithic_LabelMask_External_EndUser
// Abbreviation: Raster_Mono_Msk_Ext_EU

process RASTER_MONO_MSK_EXT_EU {
    tag "$meta.id"
    label 'process_medium'

    conda "bioconda::raster=1.0.0"
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://depot.galaxyproject.org/singularity/raster:1.0.0--pyhdfd78af_0' :
        'biocontainers/raster:1.0.0--pyhdfd78af_0' }"

    input:
    tuple val(meta), path(geojson), val(image_shape)

    output:
    tuple val(meta), path("*_labels.tif"), emit: labels
    tuple val("${task.process}"), val('raster'), eval('python -m raster --version 2>&1 | sed 's/.*//g''), emit: versions_raster, topic: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    def args = task.ext.args ?: ''
    def prefix = task.ext.prefix ?: "${meta.id}"
    """
    python -m raster \\
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
