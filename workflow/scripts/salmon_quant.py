"""salmon quant single-end (bioskills modules/salmon; DRS)."""

import os
import sys

from snakemake.shell import shell

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import docker_wrapper  # noqa: E402

log = snakemake.log_fmt_shell(stdout=True, stderr=True)
prefix, binary = docker_wrapper.docker_wrapper_binary(
    snakemake.config, "salmon", "salmon_bin", "salmon"
)
outdir = str(snakemake.params.outdir)
shell(f"mkdir -p {outdir}")
shell(
    f"{prefix}{binary} quant -i {snakemake.input.index} -l {snakemake.params.libtype} "
    f"-r {snakemake.input.reads} -p {snakemake.threads} --validateMappings "
    f"-o {outdir} {snakemake.params.extra} {log}"
)
