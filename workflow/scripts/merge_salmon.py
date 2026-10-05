"""Merge salmon quant.sf into count and TPM matrices."""

import csv
from pathlib import Path

samples = list(snakemake.params.samples)
names = []
count_map = {}
tpm_map = {}
for sample, path in zip(samples, snakemake.input.quants):
    with open(path, newline="") as fh:
        reader = csv.DictReader(fh, delimiter="\t")
        for row in reader:
            name = row["Name"]
            if name not in count_map:
                names.append(name)
                count_map[name] = {}
                tpm_map[name] = {}
            count_map[name][sample] = row["NumReads"]
            tpm_map[name][sample] = row["TPM"]

Path(snakemake.output.counts).parent.mkdir(parents=True, exist_ok=True)

def write_matrix(path, data):
    with open(path, "w", newline="") as fh:
        writer = csv.writer(fh, delimiter="\t")
        writer.writerow(["transcript", *samples])
        for name in names:
            writer.writerow([name, *[data[name].get(s, "0") for s in samples]])

write_matrix(snakemake.output.counts, count_map)
write_matrix(snakemake.output.tpm, tpm_map)
