"""edgeR DE from salmon counts (bioskills modules/edger)."""

from __future__ import annotations

import csv
import os
import sys
import tempfile
from collections import OrderedDict
from pathlib import Path

from snakemake.shell import shell

with open(snakemake.input.counts, newline="") as fh:
    reader = csv.DictReader(fh, delimiter="\t")
    samples = [c for c in reader.fieldnames if c != "transcript"]
    rows = list(reader)

coldata = OrderedDict()
with open(snakemake.input.coldata, newline="") as fh:
    for row in csv.DictReader(fh, delimiter="\t"):
        coldata[row["sample"]] = row["condition"]

keep = [s for s in samples if s in coldata]
uniq = []
for s in keep:
    g = coldata[s]
    if g and g != "NA" and g not in uniq:
        uniq.append(g)

Path(snakemake.output.table).parent.mkdir(parents=True, exist_ok=True)
if len(uniq) < 2:
    Path(snakemake.output.table).write_text("logFC\tlogCPM\tPValue\tFDR\n")
    sys.exit(0)

pair = str(snakemake.params.pair or "").strip()
if pair and "," in pair:
    ctrl, treat = [x.strip() for x in pair.split(",", 1)]
else:
    ctrl, treat = uniq[0], uniq[1]

cpm_cutoff = snakemake.params.cpm_cutoff
min_samples = snakemake.params.min_samples
adjust = snakemake.params.adjust

with tempfile.TemporaryDirectory() as tmp:
    counts_path = os.path.join(tmp, "counts.tsv")
    coldata_path = os.path.join(tmp, "coldata.tsv")
    r_path = os.path.join(tmp, "edger.R")
    with open(counts_path, "w", newline="") as fh:
        writer = csv.writer(fh, delimiter="\t")
        writer.writerow(["transcript", *keep])
        for row in rows:
            writer.writerow([row["transcript"], *[row[s] for s in keep]])
    with open(coldata_path, "w", newline="") as fh:
        writer = csv.writer(fh, delimiter="\t")
        writer.writerow(["sample", "condition"])
        for s in keep:
            writer.writerow([s, coldata[s]])
    rscript = f"""
suppressPackageStartupMessages(library(edgeR))
countData <- read.table("{counts_path}", header=TRUE, row.names=1, sep="\\t", check.names=FALSE)
coldata <- read.table("{coldata_path}", header=TRUE, row.names=1, sep="\\t", check.names=FALSE)
coldata <- coldata[colnames(countData), , drop=FALSE]
group <- factor(coldata$condition)
y <- DGEList(counts=countData, group=group)
keep <- rowSums(cpm(y) > {cpm_cutoff}) >= {min_samples}
y <- y[keep, , keep.lib.sizes=FALSE]
y <- calcNormFactors(y)
y <- estimateDisp(y)
et <- exactTest(y, pair=c("{ctrl}", "{treat}"))
res <- topTags(et, n=Inf, adjust.method="{adjust}")
write.table(res$table, "{snakemake.output.table}", sep="\\t", quote=FALSE, row.names=TRUE, col.names=NA)
"""
    Path(r_path).write_text(rscript)
    log = snakemake.log_fmt_shell(stdout=True, stderr=True)
    shell(f"Rscript {r_path} {log}")
