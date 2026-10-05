"""samtools flagstat wrapper."""

from __future__ import annotations

import os
import sys

from snakemake.shell import shell

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import docker_wrapper  # noqa: E402

log = snakemake.log_fmt_shell(stdout=False, stderr=True)
sam_prefix, sam_bin = docker_wrapper.docker_wrapper_binary(
    snakemake.config, "minimap2", "samtools_bin", "samtools"
)
out = str(snakemake.output.txt)
shell(f"mkdir -p {os.path.dirname(out)}")
shell(f"{sam_prefix}{sam_bin} flagstat {snakemake.input.bam} > {out}{log}")
