"""FLAIR bam2bed12 via bedtools (bioskills modules/flair)."""

import os
import sys
from pathlib import Path

from snakemake.shell import shell

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import docker_wrapper  # noqa: E402

log = snakemake.log_fmt_shell(stdout=False, stderr=True)
docker_prefix, tool_bin = docker_wrapper.docker_wrapper_binary(
    snakemake.config,
    "flair",
    "bedtools_bin",
    "bedtools",
)

out_file = str(snakemake.output.bed12)
out_dir = os.path.dirname(out_file)
if out_dir and not os.path.exists(out_dir):
    os.makedirs(out_dir)

helper = Path(__file__).resolve().parent / "bed12_add_trailing_commas.py"

shell(
    f"{docker_prefix}{tool_bin} bamtobed -bed12 -i {snakemake.input.bam}"
    f" | {sys.executable} {helper} > {out_file}{log}"
)
