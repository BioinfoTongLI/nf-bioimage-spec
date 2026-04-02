// Full name:    SpotObjectDetection_Monolithic_Points_External_Developer
// Abbreviation: ObjDet_Mono_Pts_Ext_Dev

process OBJDET_MONO_PTS_EXT_DEV {
    tag "$meta.id"
    label 'process_medium'

    conda "bioconda::objdet=1.0.0"
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://depot.galaxyproject.org/singularity/objdet:1.0.0--pyhdfd78af_0' :
        'biocontainers/objdet:1.0.0--pyhdfd78af_0' }"

    input:
    tuple val(meta), path(image), path(model_weights)

    output:
    tuple val(meta), path("*_detections.{csv,tif}"), emit: detections
    tuple val("${task.process}"), val('objdet'), eval('python -m objdet --version 2>&1 | sed 's/.*//g''), emit: versions_objdet, topic: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    def args = task.ext.args ?: ''
    def prefix = task.ext.prefix ?: "${meta.id}"
    """
    python -m objdet \\
        --input $image \\
        --model ${model_weights} \\
        --output ${prefix}_detections.csv \\
        $args
    """

    stub:
    def prefix = task.ext.prefix ?: "${meta.id}"
    """
    touch ${prefix}_detections.csv
    """
}
