"""BAM -> FASTQ.gz via samtools."""

import os
import sys

from snakemake.shell import shell

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import docker_wrapper  # noqa: E402

log = snakemake.log_fmt_shell(stdout=False, stderr=True)
sam_prefix, sam_bin = docker_wrapper.docker_wrapper_binary(
    snakemake.config, "minimap2", "samtools_bin", "samtools"
)
out = str(snakemake.output.fastq)
shell(f"mkdir -p {os.path.dirname(out)}")
shell(
    f"{sam_prefix}{sam_bin} fastq -@ {snakemake.threads} {snakemake.input.bam} "
    f"| gzip -c > {out}{log}"
)
