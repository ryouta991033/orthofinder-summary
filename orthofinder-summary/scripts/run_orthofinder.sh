#!/bin/bash
# Run OrthoFinder

set -e

FASTA_DIR=$1
OUTDIR=$2
THREADS=${3:-8}

if [ $# -lt 2 ]; then
  echo "Usage: run_orthofinder.sh <fasta_dir> <output_dir> [threads]"
  exit 1
fi

orthofinder \
  -t "$THREADS" \
  -a "$THREADS" \
  -f "$FASTA_DIR" \
  -o "$OUTDIR"
