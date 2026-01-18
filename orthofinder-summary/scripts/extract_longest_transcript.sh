#!/bin/bash
# Identify longest CDS per gene

set -e

GFF=$1
Protein=$2
PREFIX=$3

if [ $# -lt 3 ]; then
  echo "Usage: extract_longest_transcript.sh <gff> <protein.fasta> <prefix>"
  exit 1
fi

# transcript ID - gene ID
awk '$3=="mRNA"{print $9}' "$GFF" \
| awk -F ";" '{print $1,$2}' \
| awk -F "ID=" '{print $1,$2}' \
| awk -F "Parent=gene-" 'BEGIN{OFS="\t"}{print $1,$2}' \
> "${PREFIX}.transcript_gene.txt"

# transcript length
bioawk -c fastx 'BEGIN{OFS="\t"}{print $name,length($seq)}' "$Protein" \
> "${PREFIX}.transcript_length.txt"

# merge & sort
join -1 1 -2 1 \
  <(sort -k1 "${PREFIX}.transcript_length.txt") \
  <(sort -k1 "${PREFIX}.transcript_gene.txt") \
| awk 'BEGIN{OFS="\t"}{print $3,$1,$2}' \
| sort -k1,1 -k3,3nr \
> "${PREFIX}.gene_transcript_length.txt"

# select longest
awk 'BEGIN{gene=""}{if($1!=gene){print; gene=$1}}' \
"${PREFIX}.gene_transcript_length.txt" \
> "${PREFIX}.longest.txt"

# extract CDS
seqtk subseq "$Protein" <(awk '{print $2}' "${PREFIX}.longest.txt") | sed 's/\./X/g' \
> "${PREFIX}.Protein.longest.fasta"

#extract gene_list
awk '{print $1}' "${PREFIX}.longest.txt" > ${PREFIX}.reheader.fasta.txt
