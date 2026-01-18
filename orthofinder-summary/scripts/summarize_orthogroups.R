#!/usr/bin/env Rscript

args <- commandArgs(trailingOnly = TRUE)

# =========================
# --help / -h
# =========================
if (length(args) == 0 || "--help" %in% args || "-h" %in% args) {
  cat(
    "\nOrthogroup summary tool\n",
    "=======================\n\n",
    "Summarize OrthoFinder results into a single TSV file.\n",
    "This script focuses on numerical aggregation only.\n\n",
    "Usage:\n",
    "  Rscript orthogroup_summary.R \\\n",
    "    --gene_count GeneCount.tsv \\\n",
    "    --orthogroups Orthogroups.tsv \\\n",
    "    --species XL,XT \\\n",
    "    --out_prefix XT_XL\n\n",
    "Options:\n",
    "  --gene_count     GeneCount.tsv from OrthoFinder\n",
    "  --orthogroups    Orthogroups.tsv from OrthoFinder\n",
    "  --species        Comma-separated species names (e.g. XL,XT)\n",
    "  --out_prefix     Prefix for output files\n",
    "  --help, -h       Show this help message and exit\n\n",
    "Output:\n",
    "  <out_prefix>.summary.tsv\n\n",
    "Example:\n",
    "  Rscript orthogroup_summary.R \\\n",
    "    --gene_count Orthogroups.GeneCount.tsv \\\n",
    "    --orthogroups Orthogroups.tsv \\\n",
    "    --species XL,XT \\\n",
    "    --out_prefix XL_XT\n\n"
  )
  quit(status = 0)
}

# =========================
# argument parser
# =========================
get_arg <- function(flag) {
  idx <- which(args == flag)
  if (length(idx) == 0 || idx == length(args)) {
    stop(paste("Missing value for", flag))
  }
  args[idx + 1]
}

gene_count_file <- get_arg("--gene_count")
orthogroups_file <- get_arg("--orthogroups")
species <- strsplit(get_arg("--species"), ",")[[1]]
out_prefix <- get_arg("--out_prefix")

## ===============================
## Orthogroup summary (CLI version)
## ===============================


suppressPackageStartupMessages({
  library(dplyr)
  library(readr)
})

## ---------- argument parsing ----------
args <- commandArgs(trailingOnly = TRUE)

get_arg <- function(flag) {
  pos <- match(flag, args)
  if (is.na(pos)) return(NULL)
  args[pos + 1]
}

gene_count_file <- get_arg("--gene_count")
orthogroups_file <- get_arg("--orthogroups")
species_arg <- get_arg("--species")
out_prefix <- get_arg("--out_prefix")

## ---------- argument check ----------
if (is.null(gene_count_file) ||
    is.null(orthogroups_file) ||
    is.null(species_arg) ||
    is.null(out_prefix)) {

  stop(
    "\nUsage:\n",
    "Rscript summarize_orthogroups.R",
    "--gene_count GeneCount.tsv ",
    "--orthogroups Orthogroups.tsv ",
    "--species species1,species2",
    "--out_prefix species_1,species_2\n"
  )
}

species <- unlist(strsplit(species_arg, ","))

## ---------- read data ----------
gene_count <- read_tsv(gene_count_file, show_col_types = FALSE)
orthogroups <- read_tsv(orthogroups_file, show_col_types = FALSE)

## ---------- column name safety ----------
colnames(gene_count) <- make.unique(colnames(gene_count))
colnames(orthogroups) <- make.unique(colnames(orthogroups))

## ---------- column existence check ----------
stopifnot(
  all(species %in% colnames(gene_count)),
  all(species %in% colnames(orthogroups)),
  "Orthogroup" %in% colnames(gene_count),
  "Orthogroup" %in% colnames(orthogroups)
)

## ---------- subset ----------
gene_count_sub <- gene_count %>%
  select(Orthogroup, Total, all_of(species))

orthogroups_sub <- orthogroups %>%
  select(Orthogroup, all_of(species))

## ---------- merge ----------
merged <- gene_count_sub %>%
  left_join(orthogroups_sub,
            by = "Orthogroup",
            suffix = c(".count", ".genes"))

## ---------- filters ----------
shared <- merged %>%
  filter(if_all(ends_with(".count"), ~ .x >= 1))

species_only <- lapply(species, function(sp) {
  others <- setdiff(species, sp)
  merged %>%
    filter(.data[[paste0(sp, ".count")]] >= 1,
           if_all(paste0(others, ".count"), ~ .x == 0))
})
names(species_only) <- species

## ---------- summary ----------
summary_table <- merged %>%
  summarise(
    total_orthogroups = n(),
    shared = sum(if_all(ends_with(".count"), ~ .x >= 1))
  )

for (sp in species) {
  summary_table[[paste0(sp, "_only")]] <-
    nrow(species_only[[sp]])
}

## ---------- output ----------
write_tsv(shared,
          paste0(out_prefix, "_shared.tsv"))

for (sp in species) {
  write_tsv(species_only[[sp]],
            paste0(out_prefix, "_", sp, "_only.tsv"))
}

write_tsv(summary_table,
          paste0(out_prefix, "_summary.tsv"))

message("Orthogroup analysis finished successfully.")
