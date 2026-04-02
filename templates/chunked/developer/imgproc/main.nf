// Full name:    ImageProcessing_Chunked_Image_Internal_Developer
// Abbreviation: ImgProc_Chnk_Img_Int_Dev

process IMGPROC_CHNK_IMG_INT_DEV {
    tag "$meta.id"
    label 'process_medium'

    conda "bioconda::imgproc=1.0.0"
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://depot.galaxyproject.org/singularity/imgproc:1.0.0--pyhdfd78af_0' :
        'biocontainers/imgproc:1.0.0--pyhdfd78af_0' }"

    input:
    tuple val(meta), path(zarr_dir), path(model_weights)

    output:
    tuple val(meta), path(zarr_dir), emit: processed
    tuple val("${task.process}"), val('imgproc'), eval('python -m imgproc --version 2>&1 | sed 's/.*//g''), emit: versions_imgproc, topic: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    def args = task.ext.args ?: ''
    def prefix = task.ext.prefix ?: "${meta.id}"
    """
    python -m imgproc \\
        --input-zarr ${zarr_dir} \\
        --output-group processed \\
        --model ${model_weights} \\
        $args
    """

    stub:
    def prefix = task.ext.prefix ?: "${meta.id}"
    """
    touch ${prefix}_processed.tif
    """
}
