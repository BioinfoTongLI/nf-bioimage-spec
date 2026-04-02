// Full name:    SegmentationToVector_Chunked_Vector_Internal_EndUser
// Abbreviation: Seg2Vec_Chnk_Vec_Int_EU

process SEG2VEC_CHNK_VEC_INT_EU {
    tag "$meta.id"
    label 'process_high'

    conda "bioconda::seg2vec=1.0.0"
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://depot.galaxyproject.org/singularity/seg2vec:1.0.0--pyhdfd78af_0' :
        'biocontainers/seg2vec:1.0.0--pyhdfd78af_0' }"

    input:
    tuple val(meta), path(zarr_dir)

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
        --input-zarr ${zarr_dir} \\
        --output ${prefix}_labels.geojson \\
        $args
    """

    stub:
    def prefix = task.ext.prefix ?: "${meta.id}"
    """
    touch ${prefix}_labels.geojson
    """
}
