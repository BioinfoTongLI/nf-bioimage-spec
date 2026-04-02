// Full name:    FeatureExtraction_Chunked_Tabular_Internal_EndUser
// Abbreviation: FeatExt_Chnk_Tab_Int_EU

process FEATEXT_CHNK_TAB_INT_EU {
    tag "$meta.id"
    label 'process_high'

    conda "bioconda::featext=1.0.0"
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://depot.galaxyproject.org/singularity/featext:1.0.0--pyhdfd78af_0' :
        'biocontainers/featext:1.0.0--pyhdfd78af_0' }"

    input:
    tuple val(meta), path(zarr_dir)

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
        --input-zarr ${zarr_dir} \\
        --output ${prefix}_features.csv \\
        $args
    """

    stub:
    def prefix = task.ext.prefix ?: "${meta.id}"
    """
    touch ${prefix}_features.csv
    """
}
