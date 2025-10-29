process BATCHCORRECTION {

    tag "Performing Barch Correction"
    label 'process_medium'
    container 'syedsazaidi/scratch-batchcor:V1'

  // publish everything under data/ and figures/ preserving structure,
  // and the HTML under report/
//   publishDir "${params.outdir}/${params.project_name}", mode: 'copy', overwrite: true
    // publishDir "${params.outdir}/${params.project_name}",
    //         mode: 'copy',
    //         overwrite: true
    publishDir "SCRATCH-BatchCorrection_output",
            mode: 'copy',
            overwrite: true

    cpus 4
    memory '16 GB'
    errorStrategy 'terminate'

    input:
    path seurat_object
    path notebook
    path config

    // These are the only paths Nextflow will publish.
    output:
    path "report/${notebook.baseName}.html", emit: report,  optional: true
    path "figures/**",                     emit: figures, optional: true
    path "data/**",                        emit: data,    optional: true

    when:
    task.ext.when == null || task.ext.when

    /*
    * Build Quarto -P params safely (quote values!).
    */
    script:

    // helper to single-quote values and escape any single quotes inside
    def q = { v -> "'${v.toString().replace("'", "'\\''")}'" }

    // build flat "-P key:value" list with safe quoting for things containing commas/semicolons
    def parts = []
    parts << "-P seurat_object:${seurat_object}"
    parts << "-P project_name:${params.project_name}"
    parts << "-P input_integration_method:${params.input_integration_method}"
    parts << "-P input_target_variables:${params.input_target_variables.replaceAll(',', ';')}"
    parts << "-P input_batch_step:${params.input_batch_step}"
    parts << "-P exclude_labels:${params.exclude_labels.replaceAll(',', ';')}"
    // for label_candidates, include quotes because of semicolons
    parts << "-P label_candidates:'${params.label_candidates.replaceAll(',', ';')}'"
    parts << "-P n_hvgs:${params.n_hvgs}"
    parts << "-P n_pcs:${params.n_pcs}"
    parts << "-P n_threads:${params.n_threads}"
    parts << "-P n_memory:${params.n_memory}"
    // IMPORTANT: do NOT quote $PWD so the shell expands it
    parts << "-P work_directory:$PWD"

    def param_file = parts.join(' ')

    """
    set -euo pipefail

    # ensure these roots exist so the globs always match
    mkdir -p report figures data

    # render (options first, then params)
    quarto render --execute ${notebook} ${param_file}
    """
}


// process BATCHCORRECTION {

//     tag "Performing Barch Correction"
//     label 'process_medium'

//     // container 'oandrefonseca/scratch-cnv:main'
//     // container '/home/sazaidi/Softwares/SCRATCH-CNV-main/scratch-cnv.sif'
//     // container 'syedsazaidi/scratch-cnv:latest'
//     container 'syedsazaidi/scratch-batchcor:V1'
//     publishDir "${params.outdir}/${params.project_name}", mode: 'copy', overwrite: true

//     // // publishDir "${params.outdir}/${params.project_name}", mode: 'copy', overwrite: true
//     // publishDir "${params.outdir ?: "${launchDir}/results"}/${params.project_name ?: 'project'}",
//     //         mode: 'copy', overwrite: true
//     cpus  4
//     memory '16 GB'
//     errorStrategy 'terminate'


//     input:
//         path(seurat_object)
//         path(notebook)
//         path(config)


//     output:
//         path("data/**")                              , emit: data,       optional: true
//         path("figures/**")                           , emit: figures
//         path("report/${notebook.baseName}.html")     , emit: report,     optional: true
//         path("_freeze/${notebook.baseName}")              , emit: cache
//         // path("_freeze/${notebook.baseName}")        , emit: cache, optional: true

//     when:
//         task.ext.when == null || task.ext.when
    
    

//     script:
        
//         def param_file = task.ext.args ? "-P seurat_object:${seurat_object}  -P ${task.ext.args}" : ""
//         // def param_file = task.ext.args ? "-P seurat_object:${seurat_object} -P reference_table:${reference_table} -P ${task.ext.args}" : ""
//         """
//         quarto render --execute ${notebook} ${param_file}
//         mkdir -p figures data report
//         """
//     stub:
//         def param_file = task.ext.args ? "-P seurat_object:${seurat_object}  -P ${task.ext.args}" : ""
//         """
//         mkdir -p data _freeze/${notebook.baseName}
//         mkdir -p _freeze/DUMMY/figure-html

//         touch _freeze/DUMMY/figure-html/FILE.png

//         touch data/${params.project_name}_*.RDS
//         # touch _freeze/${notebook.baseName}/${notebook.baseName}.html

//         mkdir -p report
//         touch report/${notebook.baseName}.html

//         echo ${param_file} > _freeze/${notebook.baseName}/params.yml
//         """

// }
