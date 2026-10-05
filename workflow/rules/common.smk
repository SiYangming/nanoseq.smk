import pandas as pd
from snakemake.utils import validate

samples = (
    pd.read_csv(config["sample_sheet"], sep="\t", dtype=str)
    .set_index("sample", drop=False)
    .sort_index()
)
validate(samples, schema="../schemas/samples.schema.yaml")
validate(config, schema="../schemas/config.schema.yaml")

ENTRY = config["entrypoint"]
FASTA = config["fasta"]
GTF = config.get("gtf") or ""
SAMPLE_IDS = list(samples["sample"])


def _col(sample, name):
    if name not in samples.columns:
        return None
    val = samples.loc[sample, name]
    if pd.isna(val) or not str(val).strip():
        return None
    return str(val)


def sample_pod5(sample):
    return _col(sample, "pod5")


def sample_reads(sample):
    return _col(sample, "reads")


def sample_bam_sheet(sample):
    return _col(sample, "bam")


def sample_condition(sample):
    return _col(sample, "condition")


def raw_reads(wildcards):
    if ENTRY == "pod5":
        return f"results/dorado/{wildcards.sample}/{wildcards.sample}.fastq"
    reads = sample_reads(wildcards.sample)
    if not reads:
        raise ValueError(
            f"fastq entrypoint requires a reads column for {wildcards.sample}"
        )
    return reads


def clean_reads(wildcards):
    if ENTRY == "bam":
        reads = sample_reads(wildcards.sample)
        if reads:
            return reads
        return f"results/qc/{wildcards.sample}/{wildcards.sample}.frombam.fastq.gz"
    return f"results/qc/{wildcards.sample}/{wildcards.sample}.q{config['min_qscore']}.fastq.gz"


def aligned_bam(wildcards):
    if ENTRY == "bam":
        bam = sample_bam_sheet(wildcards.sample)
        if not bam:
            raise ValueError(
                f"bam entrypoint requires a bam column for {wildcards.sample}"
            )
        return bam
    return f"results/minimap2/{wildcards.sample}/{wildcards.sample}.bam"


def has_conditions():
    if not config.get("run_edger", True):
        return False
    if "condition" not in samples.columns:
        return False
    groups = [sample_condition(s) for s in SAMPLE_IDS]
    groups = [g for g in groups if g]
    return len(set(groups)) >= 2


def pipeline_targets():
    targets = expand("results/qc/{sample}/{sample}.seqkit.stats.tsv", sample=SAMPLE_IDS)
    targets += expand("results/align/{sample}/{sample}.flagstat.txt", sample=SAMPLE_IDS)
    targets += expand(
        "results/flair/{sample}/{sample}.flair.collapse.fasta", sample=SAMPLE_IDS
    )
    targets.append("results/stringtie/merge/stringtie_merged.gtf")
    targets.append("results/gffcompare/nanoseq.annotated.gtf")
    targets += expand("results/salmon/{sample}/quant.sf", sample=SAMPLE_IDS)
    targets.append("results/quant/transcript_counts.tsv")
    if has_conditions():
        targets.append("results/edger/de_transcripts.tsv")
    if config.get("run_polya", False):
        targets.append("results/polya/polyA_sites.tsv")
    return targets
