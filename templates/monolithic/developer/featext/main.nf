// Full name:    FeatureExtraction_Monolithic_Tabular_External_Developer
// Abbreviation: FeatExt_Mono_Tab_Ext_Dev

process FEATEXT_MONO_TAB_EXT_DEV {
    tag "$meta.id"
    label 'process_medium'

    conda "bioconda::featext=1.0.0"
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://depot.galaxyproject.org/singularity/featext:1.0.0--pyhdfd78af_0' :
        'biocontainers/featext:1.0.0--pyhdfd78af_0' }"

    input:
    tuple val(meta), path(image), path(labels)

    output:
    tuple val(meta), path("*_features.csv"), emit: features
    tuple val("${task.process}"), val('featext'), eval('python -m featext --version 2>&1 | sed 's/.*//g''), emit: versions_featext, topic: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    def args = task.ext.args ?: ''
    def prefix = task.ext.prefix ?: "${meta.id}"
    """
    python -m featext \\
        --input $image \\
        --output ${prefix}_features.csv \\
        $args
    """

    stub:
    def prefix = task.ext.prefix ?: "${meta.id}"
    """
    touch ${prefix}_features.csv
    """
}
