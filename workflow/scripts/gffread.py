"""gffread transcripts FASTA from merged GTF."""

import os
import sys

from snakemake.shell import shell

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import docker_wrapper  # noqa: E402

log = snakemake.log_fmt_shell(stdout=True, stderr=True)
prefix, binary = docker_wrapper.docker_wrapper_binary(
    snakemake.config, "gffread", "gffread_bin", "gffread"
)
out = str(snakemake.output.fasta)
shell(f"mkdir -p {os.path.dirname(out)}")
shell(
    f"{prefix}{binary} {snakemake.input.gtf} -g {snakemake.input.fasta} "
    f"-w {out} {log}"
)
