#!/usr/bin/env nextflow

include {  BATCHCORRECTION     } from '../../modules/local/batch_correction/main.nf'


workflow SCRATCH_BC {

    take:
        ch_seurat_object     // channel: []
        // ch_reference_table   // channel: []

    main:

        // Importing notebook
        ch_notebook_batchcorr  = Channel.fromPath(params.notebook_batchcorr, checkIfExists: true)
        

        // Quarto configurations
        ch_template    = Channel.fromPath(params.template, checkIfExists: true)
            .collect()
        ch_page_config = Channel.fromPath(params.page_config, checkIfExists: true)
            .collect()


        // Version channel
        ch_versions = Channel.empty()

        // Run BatCorrection
        if (!params.skip_BatchCorr) { 
            BATCHCORRECTION(
                ch_seurat_object,
                // ch_reference_table,
                ch_notebook_batchcorr,
                ch_page_config 
            )
        }


    emit:
        versions = ch_versions

}


