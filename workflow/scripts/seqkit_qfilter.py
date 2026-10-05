"""seqkit quality filter Q >= min_q (Benagen DRS pass reads)."""

import os
import sys

from snakemake.shell import shell

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import docker_wrapper  # noqa: E402

log = snakemake.log_fmt_shell(stdout=False, stderr=True)
prefix, binary = docker_wrapper.docker_wrapper_binary(
    snakemake.config, "seqkit", "seqkit_bin", "seqkit"
)
out = str(snakemake.output.fastq)
min_q = int(snakemake.params.min_q)
shell(f"mkdir -p {os.path.dirname(out)}")
shell(
    f"{prefix}{binary} seq -Q {min_q} -j {snakemake.threads} "
    f"{snakemake.input.reads} | gzip -c > {out}{log}"
)
