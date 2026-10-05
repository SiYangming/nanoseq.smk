"""seqkit stats wrapper (bioskills modules/seqkit)."""

from __future__ import annotations

import os
import sys

from snakemake.shell import shell

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import docker_wrapper  # noqa: E402

log = snakemake.log_fmt_shell(stdout=False, stderr=True)
prefix, binary = docker_wrapper.docker_wrapper_binary(
    snakemake.config, "seqkit", "seqkit_bin", "seqkit"
)
out = str(snakemake.output.tsv)
shell(f"mkdir -p {os.path.dirname(out)}")
shell(
    f"{prefix}{binary} stats -a -T -j {snakemake.threads} "
    f"{snakemake.input.reads} > {out}{log}"
)
