"""salmon index (bioskills modules/salmon)."""

import os
import sys

from snakemake.shell import shell

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import docker_wrapper  # noqa: E402

log = snakemake.log_fmt_shell(stdout=True, stderr=True)
prefix, binary = docker_wrapper.docker_wrapper_binary(
    snakemake.config, "salmon", "salmon_bin", "salmon"
)
idx = str(snakemake.output.idx)
shell(f"mkdir -p {os.path.dirname(idx)}")
shell(
    f"{prefix}{binary} index -t {snakemake.input.transcripts} -i {idx} "
    f"-k {snakemake.params.kmer} -p {snakemake.threads} {snakemake.params.extra} {log}"
)
