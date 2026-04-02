// Full name:    ObjectSegmentation_Monolithic_Vector_External_EndUser
// Abbreviation: ObjSeg_Mono_Vec_Ext_EU

process OBJSEG_MONO_VEC_EXT_EU {
    tag "$meta.id"
    label 'process_medium'

    conda "bioconda::objseg=1.0.0"
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://depot.galaxyproject.org/singularity/objseg:1.0.0--pyhdfd78af_0' :
        'biocontainers/objseg:1.0.0--pyhdfd78af_0' }"

    input:
    tuple val(meta), path(image)

    output:
    tuple val(meta), path("*_labels.{geojson,wkt}"), emit: polygons
    tuple val("${task.process}"), val('objseg'), eval('python -m objseg --version 2>&1 | sed 's/.*//g''), emit: versions_objseg, topic: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    def args = task.ext.args ?: ''
    def prefix = task.ext.prefix ?: "${meta.id}"
    """
    python -m objseg \\
        --input $image \\
        --output ${prefix}_labels.geojson \\
        $args
    """

    stub:
    def prefix = task.ext.prefix ?: "${meta.id}"
    """
    touch ${prefix}_labels.geojson
    """
}
