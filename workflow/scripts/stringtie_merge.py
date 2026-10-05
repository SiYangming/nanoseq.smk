"""stringtie --merge (bioskills modules/stringtie)."""

import os
import sys

from snakemake.shell import shell

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import docker_wrapper  # noqa: E402

log = snakemake.log_fmt_shell(stdout=True, stderr=True)
docker_prefix, tool_bin = docker_wrapper.docker_wrapper_binary(
    snakemake.config,
    "stringtie",
    "stringtie_bin",
    "stringtie",
)

out = str(snakemake.output.merged_gtf)
shell(f"mkdir -p {os.path.dirname(out)}")
shell(
    f"{docker_prefix}{tool_bin} --merge {snakemake.params.gtf_arg} -o {out} "
    f"-l {snakemake.params.label} -m {snakemake.params.min_len} -p {snakemake.threads} "
    f"{snakemake.input.gtf_list} {snakemake.params.extra} {log}"
)
