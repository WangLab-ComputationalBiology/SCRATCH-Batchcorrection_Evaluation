# SCRATCH-BatchCorrection_Evaluation
## Introduction

SCRATCH-BatchCorrection_Evaluation aligns multi-sample scRNA-seq datasets and quantitatively evaluates batch removal vs biological signal retention. It supports multiple integration strategies (Harmony, Seurat v5 RPCA/CCA, FastMNN) and generates standardized before/after visualizations and metrics (e.g., LISI, kBET, silhouette, graph connectivity). The module is implemented as three QMD notebooks and orchestrated via Nextflow for scalable, reproducible runs on Docker or Singularity. It can be used standalone or as part of the SCRATCH ecosystem.

## Prerequisites

Nextflow ≥ 21.04.0
Java ≥ 8
Docker or Singularity
Git

### R packages (handled by container):
Seurat (v5), SeuratObject, harmony, SeuratWrappers, batchelor, Matrix, data.table, ggplot2, patchwork, uwot, RANN, FNN, reticulate
(kBET/LISI implementations are provided within the container; no extra setup needed.)

## Installation

git clone https://github.com/WangLab-ComputationalBiology/SCRATCH-Batchcorrection_Evaluation.git

cd SCRATCH-Batchcorrection_Evaluation

main.nf — entrypoint

subworkflows/local/SCRATCH_BC.nf — scatter/gather & method fan-out

modules/local/*.nf — QMD execution wrappers

nextflow.config — default resources/containers

Parallelization occurs over methods and/or parameter grids when requested.

## Quick Start

### Minimal example (Docker)
nextflow run main.nf -profile docker \
  --input_seurat_object annotation_object.RDS \
  --input_integration_method all     
  --project_name MyBC \
  --input_target_variables   batch
  -resume

### Minimal example (Singularity)
nextflow run main.nf -profile singularity \
  --input_seurat_object annotation_object.RDS \
  --input_integration_method all     
  --project_name MyBC \
  --input_target_variables   batch
  -resume

## Typical workflow execution

prep: load object → join layers → PCA → choose batch_var

integrate: run selected correction(s) → store reductions (harmony, integrated.rpca, integrated.cca, mnn)

evaluate: same graph/UMAP recipe on raw PCA and corrected → compute/compare metrics → export report

## Key Parameters

### Parameter	Description

--project_name	Label for outputs
--work_directory	Output root (default: ./output)
--seed	Reproducibility (default: 1234)
--n_threads	Threads within R chunks

### Inputs
Parameter	Description
--input_seurat_object	annotation_object.RDS

### Method selection
Parameter	Values	Notes
--input_integration_method	all, harmony, rpca, cca, mnn (defualt: all)

## Expected Input

1. Annotated Seurat object [with a valid batch_var in meta.data, normalized data (SCTransform or log-norm); raw counts present for reference]

## Outputs

All under work_directory:

SCRATCH-BatchCorrection_output/data/CCA|RPCA|MNN|Harmony/
  <project_name>_prepped.rds
  <project_name>_integrated_<method>.rds

SCRATCH-BatchCorrection_output/figures/CCA|RPCA|MNN|Harmony/
  UMAP_before_vs_after_<method>.png
  UMAP_by_batch_<method>.png
  UMAP_by_celltype_<method>.png
  Mixing_violin_<method>.png

SCRATCH-BatchCorrection_output/reports/
  BC_summary_<project_name>.html


Metric table columns (example):

method,batch_var,k,npcs,Resolution,
iLISI_mean, iLISI_sd,
kBET_reject_rate,
ASW_batch, ASW_label,
GraphConn, PCVar_retained



## Documentation

See inline comments in subworkflows/local/SCRATCH_BC.nf and QMD notebooks for method-specific parameters and advanced usage (grid sweeps, custom dims, SCT vs log-norm).

## Contributing

Issues and PRs welcome! Please open an issue to discuss substantial changes.

## License

GNU General Public License v3.0. See LICENSE.

## Contact

sazaidi@mdanderson.org
lwang22@mdanderson.org

