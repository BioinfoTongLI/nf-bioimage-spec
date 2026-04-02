// Full name:    FilamentTreeTracing_Monolithic_SWC_Internal_EndUser
// Abbreviation: TreTrc_Mono_SWC_Int_EU

process TRETRC_MONO_SWC_INT_EU {
    tag "$meta.id"
    label 'process_high'

    conda "bioconda::fiji-tretrc=1.0.0"
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://depot.galaxyproject.org/singularity/fiji-tretrc:1.0.0--pyhdfd78af_0' :
        'biocontainers/fiji-tretrc:1.0.0--pyhdfd78af_0' }"

    input:
    tuple val(meta), path(image)

    output:
    tuple val(meta), path("*_trace.swc"), emit: traces
    tuple val("${task.process}"), val('tretrc'), eval('fiji --headless --eval 'println(System.getProperty("fiji.version"))' 2>&1 | tail -1'), emit: versions_tretrc, topic: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    def args = task.ext.args ?: ''
    def prefix = task.ext.prefix ?: "${meta.id}"
    """
    fiji --headless --run tretrc.groovy \\
        --input $image \\
        --output ${prefix}_trace.swc \\
        $args
    """

    stub:
    def prefix = task.ext.prefix ?: "${meta.id}"
    """
    touch ${prefix}_trace.swc
    """
}
