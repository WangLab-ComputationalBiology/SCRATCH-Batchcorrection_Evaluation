#!/usr/bin/env nextflow

include {  BATCHCORRECTION     } from '../../modules/local/batch_correction/main.nf'
// include {  SCEVAN       } from '../../modules/local/scevan/main.nf'
// include { COPYKAT } from '../../modules/local/copykat/main.nf' // Re-added from your first shared code for completeness


workflow SCRATCH_BC {

    take:
        ch_seurat_object     // channel: []
        // ch_reference_table   // channel: []

    main:

        // Importing notebook
        // ch_notebook_batchcorr = Channel.fromPath(params.notebook_batchcorr, checkIfExists: true)
        ch_notebook_batchcorr  = Channel.fromPath(params.notebook_batchcorr, checkIfExists: true)
        // ch_notebook_scevan    = Channel.fromPath(params.notebook_scevan, checkIfExists: true) 
        // ch_notebook_copykat = Channel.fromPath(params.notebook_copykat, checkIfExists: true) 


        // Quarto configurations
        ch_template    = Channel.fromPath(params.template, checkIfExists: true)
            .collect()
        ch_page_config = Channel.fromPath(params.page_config, checkIfExists: true)
            .collect()


        // Version channel
        ch_versions = Channel.empty()

        // Run inferCNV
        if (!params.skip_BatchCorr) { 
            BATCHCORRECTION(
                ch_seurat_object,
                // ch_reference_table,
                ch_notebook_batchcorr,
                ch_page_config 
            )
        }



        // // Run CopyKAT
        // if (!params.skip_copykat) { // Added 'if' conditions back
        //     COPYKAT(
        //         ch_seurat_object,
        //         ch_notebook_copykat,
        //         ch_page_config // Pass the *original*, simple ch_page_config
        //     )
        // }


    emit:
        versions = ch_versions

}


