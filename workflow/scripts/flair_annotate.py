"""FLAIR identify_gene_isoform (bioskills modules/flair)."""

import os
import sys

from snakemake.shell import shell

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import docker_wrapper  # noqa: E402

log = snakemake.log_fmt_shell(stdout=True, stderr=True)
docker_prefix, tool_bin = docker_wrapper.docker_wrapper_binary(
    snakemake.config,
    "flair",
    "identify_gene_isoform_bin",
    "identify_gene_isoform",
)

out_file = str(snakemake.output.annotated_bed)
out_dir = os.path.dirname(out_file)
if out_dir and not os.path.exists(out_dir):
    os.makedirs(out_dir)

shell(
    f"{docker_prefix}{tool_bin}"
    f" {snakemake.input.bed12} {snakemake.input.gtf} {out_file}"
    f"{log}"
)
