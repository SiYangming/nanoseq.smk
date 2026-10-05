"""Extract poly(A) tag BED from BAM (3' alignment end)."""

import os
import re
import subprocess
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import docker_wrapper  # noqa: E402

CONSUME_REF = set("MDN=X")
CIGAR_RE = re.compile(r"(\d+)([MIDNSHP=X])")

def align_end(pos, cigar):
    end = pos
    for length, op in CIGAR_RE.findall(cigar):
        if op in CONSUME_REF:
            end += int(length)
    return end

sam_prefix, sam_bin = docker_wrapper.docker_wrapper_binary(
    snakemake.config, "minimap2", "samtools_bin", "samtools"
)
cmd = f"{sam_prefix}{sam_bin} view {snakemake.input.bam}"
proc = subprocess.run(cmd, shell=True, check=True, capture_output=True, text=True)
out = str(snakemake.output.bed)
os.makedirs(os.path.dirname(out), exist_ok=True)
with open(out, "w") as fh:
    for line in proc.stdout.splitlines():
        if not line or line.startswith("@"):
            continue
        fields = line.split("\t")
        flag = int(fields[1])
        if flag & 4:
            continue
        chrom = fields[2]
        pos = int(fields[3])
        mapq = fields[4]
        cigar = fields[5]
        strand = "-" if flag & 16 else "+"
        end = align_end(pos, cigar)
        coord = (end - 1) if strand == "+" else pos
        fh.write(f"{chrom}\t{strand}\t{coord}\t{mapq}\n")
