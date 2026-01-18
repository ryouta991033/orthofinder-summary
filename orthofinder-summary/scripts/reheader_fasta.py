"""
Reheader FASTA using gene IDs.

Usage:
python reheader_fasta.py CDS.longest.fasta gene_list.txt output.fasta
"""

import sys

fasta = open(sys.argv[1])
names = open(sys.argv[2])
out = open(sys.argv[3], "w")

for line in fasta:
    if line.startswith(">"):
        out.write(">" + names.readline())
    else:
        out.write(line)

fasta.close()
names.close()
out.close()
