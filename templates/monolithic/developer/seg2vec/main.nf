// Full name:    SegmentationToVector_Monolithic_Vector_External_Developer
// Abbreviation: Seg2Vec_Mono_Vec_Ext_Dev

process SEG2VEC_MONO_VEC_EXT_DEV {
    tag "$meta.id"
    label 'process_medium'

    conda "bioconda::seg2vec=1.0.0"
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://depot.galaxyproject.org/singularity/seg2vec:1.0.0--pyhdfd78af_0' :
        'biocontainers/seg2vec:1.0.0--pyhdfd78af_0' }"

    input:
    tuple val(meta), path(labels)

    output:
    tuple val(meta), path("*_polygons.geojson"), emit: polygons
    tuple val("${task.process}"), val('seg2vec'), eval('python -m seg2vec --version 2>&1 | sed 's/.*//g''), emit: versions_seg2vec, topic: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    def args = task.ext.args ?: ''
    def prefix = task.ext.prefix ?: "${meta.id}"
    """
    python -m seg2vec \\
        --input $labels \\
        --output ${prefix}_labels.geojson \\
        $args
    """

    stub:
    def prefix = task.ext.prefix ?: "${meta.id}"
    """
    touch ${prefix}_labels.geojson
    """
}
