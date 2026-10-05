"""gffcompare wrapper."""

import os
import sys

from snakemake.shell import shell

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import docker_wrapper  # noqa: E402

log = snakemake.log_fmt_shell(stdout=True, stderr=True)
prefix, binary = docker_wrapper.docker_wrapper_binary(
    snakemake.config, "gffcompare", "gffcompare_bin", "gffcompare"
)
out_prefix = str(snakemake.params.prefix)
shell(f"mkdir -p {os.path.dirname(out_prefix)}")
shell(
    f"{prefix}{binary} {snakemake.params.extra} -r {snakemake.input.ref} "
    f"-o {out_prefix} {snakemake.input.merged} {log}"
)
dest = str(snakemake.output.annotated)
candidates = [
    dest,
    out_prefix + ".annotated.gtf",
    out_prefix + ".combined.gtf",
]
src = next((path for path in candidates if os.path.exists(path)), None)
if src is None:
    raise RuntimeError(
        f"gffcompare did not write annotated/combined GTF under {out_prefix}"
    )
if os.path.abspath(src) != os.path.abspath(dest):
    shell(f"cp {src} {dest}")
