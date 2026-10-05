#!/usr/bin/env python3
"""Build a tiny genome, GTF, and two FASTQ samples for workflow tests."""

from __future__ import annotations

import gzip
from pathlib import Path

ROOT = Path(__file__).resolve().parent
RES = ROOT / "resources"
RES.mkdir(parents=True, exist_ok=True)

EXON1 = "ACGTACGTACGTACGTACGTACGTACGTACGTACGTACGTACGTACGTACGTACGTACGTACGT"
EXON2 = "TGCATGCATGCATGCATGCATGCATGCATGCATGCATGCATGCATGCATGCATGCATGCATGCA"
INTRON = "NNNNGGTAAGT" + ("A" * 40) + "TTTTCAGNNNN"
GENE = EXON1 + INTRON + EXON2
FLANK = "G" * 80
CHR = FLANK + GENE + FLANK
TX = EXON1 + EXON2

fasta = RES / "tiny.fa"
fasta.write_text(f">chr1\n{CHR}\n")

e1s = len(FLANK) + 1
e1e = len(FLANK) + len(EXON1)
e2s = len(FLANK) + len(EXON1) + len(INTRON) + 1
e2e = e2s + len(EXON2) - 1

gtf = f"""\
chr1\ttiny\tgene\t{e1s}\t{e2e}\t.\t+\t.\tgene_id "g1";
chr1\ttiny\ttranscript\t{e1s}\t{e2e}\t.\t+\t.\tgene_id "g1"; transcript_id "t1";
chr1\ttiny\texon\t{e1s}\t{e1e}\t.\t+\t.\tgene_id "g1"; transcript_id "t1";
chr1\ttiny\texon\t{e2s}\t{e2e}\t.\t+\t.\tgene_id "g1"; transcript_id "t1";
"""
(RES / "tiny.gtf").write_text(gtf)

qual = "I" * len(TX)


def write_fq(path: Path, n: int, header_prefix: str) -> None:
    with gzip.open(path, "wt") as fh:
        for i in range(n):
            fh.write(f"@{header_prefix}_{i}\n{TX}\n+\n{qual}\n")


write_fq(RES / "A1.fastq.gz", 12, "A1")
write_fq(RES / "B1.fastq.gz", 12, "B1")
print(f"genome_len={len(CHR)} transcript_len={len(TX)}")
