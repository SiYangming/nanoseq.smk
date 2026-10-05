"""FLAIR collapse (bioskills modules/flair; DRS defaults)."""

import os
import sys

from snakemake.shell import shell

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import docker_wrapper  # noqa: E402

log = snakemake.log_fmt_shell(stdout=True, stderr=True)
docker_prefix, tool_bin = docker_wrapper.docker_wrapper_binary(
    snakemake.config,
    "flair",
    "flair_bin",
    "flair",
)

out_file = str(snakemake.output.consensus)
out_dir = os.path.dirname(out_file)
if out_dir and not os.path.exists(out_dir):
    os.makedirs(out_dir)

suffix = ".flair.collapse.fasta"
prefix = out_file[: -len(suffix)] if out_file.endswith(suffix) else out_file

gtf = snakemake.input.get("gtf", "")
gtf_arg = f" -f {gtf}" if gtf else ""

cmd = (
    f"{docker_prefix}{tool_bin} collapse"
    f" -q {snakemake.input.annotated_bed}"
    f" -g {snakemake.input.genome}"
    f" -r {snakemake.input.reads}"
    f" -o {prefix}"
    f" -t {snakemake.threads}"
    f"{gtf_arg}"
    f" -s {snakemake.params.min_support}"
    f" -w {snakemake.params.end_window}"
    f" --intprimingthreshold {snakemake.params.intpriming_threshold}"
)

for name in ("trust_ends", "remove_internal_priming", "stringent", "check_splice", "quiet"):
    if snakemake.params.get(name, True):
        cmd += f" --{name}"

cmd += f' --mm2_args "{snakemake.params.mm2_args}"'

extra = snakemake.params.get("extra", "")
if extra:
    cmd += f" {extra}"

shell(cmd + log)

isoforms_fa = prefix + ".isoforms.fa"
if not os.path.exists(isoforms_fa):
    raise RuntimeError(
        f"flair collapse 未生成 {isoforms_fa}（可能无满足 min_support 的 isoform，"
        f"请检查日志 {snakemake.log}）"
    )
shell(f"cp {isoforms_fa} {out_file}")
