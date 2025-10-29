# SCRATCH-BatchCorrection_Evaluation
## Introduction

SCRATCH-BatchCorrection_Evaluation aligns multi-sample scRNA-seq datasets and quantitatively evaluates batch removal vs biological signal retention. It supports multiple integration strategies (Harmony, Seurat v5 RPCA/CCA, FastMNN) and generates standardized before/after visualizations and metrics (e.g., LISI, kBET, silhouette, graph connectivity). The module is implemented as three QMD notebooks and orchestrated via Nextflow for scalable, reproducible runs on Docker or Singularity. It can be used standalone or as part of the SCRATCH ecosystem.

## Prerequisites

Nextflow ≥ 21.04.0
Java ≥ 8
Docker or Singularity/Apptainer
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
  --input_seurat_object /path/to/project_Azimuth_annotation_object.RDS \
  --project_name MyBC \
  --batch_var patient_id \
  --integration_method all \
  -resume

### Minimal example (Singularity)
nextflow run main.nf -profile singularity \
  --input_seurat_object /path/to/project_Azimuth_annotation_object.RDS \
  --project_name MyBC \
  --batch_var patient_id \
  --integration_method all \
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
--umap_npcs	NPCs for neighbors/UMAP (default auto: 25/50 based on cells)
### Inputs
Parameter	Description
--input_seurat_object	Seurat .RDS
--batch_var	Metadata column for batches (e.g., patient_id, batch, orig.ident)
### Method selection
Parameter	Values	Notes
--integration_method	harmony, rpca, cca, mnn, none	Single method run
--method_grid	comma list (e.g., harmony,rpca)	Run multiple methods in one go
--force_recompute	true/false	Recompute even if cache exists
### Evaluation knobs
Parameter	Default	Purpose
--resolution	0.25	Leiden resolution
--neighbors_k	30	k for SNN/metrics
--compute_kbet	true	Toggle kBET
--compute_lisi	true	Toggle LISI
--compute_asw	true	Silhouette (batch/biology)
--compute_gc	true	Graph connectivity

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

### Example Full Run
nextflow run main.nf -profile singularity \
  --input_seurat_object project_Azimuth_annotation_object.RDS \
  --project_name Lung_BC \
  --batch_var patient_id \
  --method_grid all \
  --neighbors_k 30 --resolution 0.25 \
  -resume

### Single-method RPCA (Seurat v5 IntegrateLayers)
nextflow run main.nf -profile docker \
  --input_seurat_object project_Azimuth_annotation_object.RDS \
  --project_name Lung_BC \
  --batch_var patient_id \
  --integration_method rpca \
  -resume


## Documentation

See inline comments in subworkflows/local/SCRATCH_BC.nf and QMD notebooks for method-specific parameters and advanced usage (grid sweeps, custom dims, SCT vs log-norm).

## Contributing

Issues and PRs welcome! Please open an issue to discuss substantial changes.

## License

GNU General Public License v3.0. See LICENSE.

## Contact

sazaidi@mdanderson.org

lwang22@mdanderson.org

