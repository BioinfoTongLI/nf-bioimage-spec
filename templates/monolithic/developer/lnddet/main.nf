// Full name:    LandmarkDetection_Monolithic_ClassMask_External_Developer
// Abbreviation: LndDet_Mono_ClsMsk_Ext_Dev

process LNDDET_MONO_CLSMSK_EXT_DEV {
    tag "$meta.id"
    label 'process_medium'

    conda "bioconda::lnddet=1.0.0"
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://depot.galaxyproject.org/singularity/lnddet:1.0.0--pyhdfd78af_0' :
        'biocontainers/lnddet:1.0.0--pyhdfd78af_0' }"

    input:
    tuple val(meta), path(image), path(model_weights)

    output:
    tuple val(meta), path("*_landmarks.{csv,tif}"), emit: landmarks
    tuple val("${task.process}"), val('lnddet'), eval('python -m lnddet --version 2>&1 | sed 's/.*//g''), emit: versions_lnddet, topic: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    def args = task.ext.args ?: ''
    def prefix = task.ext.prefix ?: "${meta.id}"
    """
    python -m lnddet \\
        --input $image \\
        --model ${model_weights} \\
        --output ${prefix}_landmarks.csv \\
        $args
    """

    stub:
    def prefix = task.ext.prefix ?: "${meta.id}"
    """
    touch ${prefix}_landmarks.csv
    """
}
