#!/bin/bash
# Extract cDNA / CDS / Protein sequences using gffread

set -e

GFF=$1
GENOME=$2
PREFIX=$3

if [ $# -lt 3 ]; then
  echo "Usage: extract_cds.sh <gff> <genome.fna> <prefix>"
  exit 1
fi

gffread \
  -E "$GFF" \
  -g "$GENOME" \
  -w "${PREFIX}.cDNA.fasta" \
  -x "${PREFIX}.CDS.fasta" \
  -y "${PREFIX}.Protein.fasta" \
  2> "${PREFIX}.gffread.log"

