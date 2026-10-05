"""QuantifyPolyA driver (bioskills modules/quantifypolya)."""

import os
from pathlib import Path

from snakemake.shell import shell

log = snakemake.log_fmt_shell(stdout=True, stderr=True)
rscript = Path(__file__).resolve().parent / "run_quantifypolya.R"
outdir = str(snakemake.params.outdir)
os.makedirs(outdir, exist_ok=True)
shell(
    f"Rscript {rscript} --bed-dir {snakemake.params.bed_dir} "
    f"--outdir {outdir} --fasta {snakemake.input.fasta} --gff {snakemake.input.gtf} "
    f"--max-gapwidth {snakemake.params.max_gapwidth} "
    f"--quant-mode {snakemake.params.quant_mode} "
    f"--threads {snakemake.threads} {log}"
)
sites = os.path.join(outdir, "polyA_sites.tsv")
if os.path.abspath(sites) != os.path.abspath(str(snakemake.output.sites)):
    shell(f"cp {sites} {snakemake.output.sites}")
