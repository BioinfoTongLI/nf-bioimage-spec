// Full name:    SpotObjectDetection_Chunked_Tabular_Internal_Developer
// Abbreviation: ObjDet_Chnk_Tab_Int_Dev

process OBJDET_CHNK_TAB_INT_DEV {
    tag "$meta.id"
    label 'process_medium'

    conda "bioconda::objdet=1.0.0"
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://depot.galaxyproject.org/singularity/objdet:1.0.0--pyhdfd78af_0' :
        'biocontainers/objdet:1.0.0--pyhdfd78af_0' }"

    input:
    tuple val(meta), path(zarr_dir), path(model_weights)

    output:
    tuple val(meta), path("*_detections.csv"), emit: detections
    tuple val("${task.process}"), val('objdet'), eval('python -m objdet --version 2>&1 | sed 's/.*//g''), emit: versions_objdet, topic: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    def args = task.ext.args ?: ''
    def prefix = task.ext.prefix ?: "${meta.id}"
    """
    python -m objdet \\
        --input-zarr ${zarr_dir} \\
        --output ${prefix}_features.csv \\
        --model ${model_weights} \\
        $args
    """

    stub:
    def prefix = task.ext.prefix ?: "${meta.id}"
    """
    touch ${prefix}_features.csv
    """
}
