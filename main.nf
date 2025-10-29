#!/usr/bin/env nextflow
nextflow.enable.dsl = 2

include { SCRATCH_BC } from './subworkflow/local/SCRATCH_BC.nf'

/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    Check mandatory parameters
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/

if (params.input_seurat_object)   { input_seurat_object = file(params.input_seurat_object) } else { exit 1, 'Please, provide a --input_seurat_object <PATH/TO/seurat_object.RDS> !' }
// if (params.input_reference_table) { input_reference_table = file(params.input_reference_table) } else { exit 1, 'Please, provide a --input_reference_table <PATH/TO/seurat_object.RDS> !' }

/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    RUN ALL WORKFLOWS
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/

workflow {

    log.info """\

        Parameters:

        Input: ${input_seurat_object}

    """

    // Mandatory inputs
    ch_seurat_object    = Channel.fromPath(params.input_seurat_object, checkIfExists: true)

    // Optional inputs
    // ch_reference_table  = Channel.fromPath(params.input_reference_table)

    // Running subworkflows
    SCRATCH_BC(
        ch_seurat_object,
        // ch_reference_table
    )

}

workflow.onComplete {
    log.info(
        workflow.success ? "\nDone! Open the following report in your browser -> ${launchDir}/${params.project_name}/report/index.html\n" :
        "Oops... Something went wrong"
    )
}
