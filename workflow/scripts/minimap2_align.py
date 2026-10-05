"""Snakemake wrapper for minimap2 align (bioskills modules/minimap2)."""

import os
import sys

from snakemake.shell import shell

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import docker_wrapper  # noqa: E402

extra = str(snakemake.params.get("extra", "")).strip()
cigar_bam = "-L" if snakemake.params.get("cigar_bam") else ""
threads = snakemake.threads
log = snakemake.log_fmt_shell(stdout=False, stderr=True)

mm2_prefix, mm2_bin = docker_wrapper.docker_wrapper_binary(
    snakemake.config,
    "minimap2",
    "minimap2_bin",
    "minimap2",
)
sam_prefix, sam_bin = docker_wrapper.docker_wrapper_binary(
    snakemake.config,
    "minimap2",
    "samtools_bin",
    "samtools",
)

reads = str(snakemake.input.reads)
reference = snakemake.input.get("reference")
ref_arg = str(reference) if reference else reads

bam = str(snakemake.output.bam)
outdir = os.path.dirname(bam)
shell(f"mkdir -p {outdir}")
log_path = str(snakemake.log)
if log_path:
    shell(f"mkdir -p {os.path.dirname(log_path)}")

shell(
    f"{mm2_prefix}{mm2_bin} {extra} -t {threads} {cigar_bam} -a {ref_arg} {reads} | "
    f"{sam_prefix}{sam_bin} sort -@ {threads} | "
    f"{sam_prefix}{sam_bin} view -@ {threads} -b -h -o {bam}{log}"
)
shell(f"{sam_prefix}{sam_bin} index {bam}{log}")

mm2_ver = shell(f"{mm2_prefix}{mm2_bin} --version 2>/dev/null | head -n1", capture=True).strip()
sam_ver = shell(f"{sam_prefix}{sam_bin} --version 2>/dev/null | head -n1", capture=True).strip()
with open(snakemake.output.versions, "w") as vf:
    vf.write("minimap2_align:\n")
    vf.write(f"    minimap2: {mm2_ver}\n")
    vf.write(f"    samtools: {sam_ver}\n")
