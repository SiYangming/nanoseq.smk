rule flair_bam2bed12:
    input:
        bam=aligned_bam
    output:
        bed12="results/flair/{sample}/{sample}.bed12"
    conda:
        "../envs/flair.yaml"
    log:
        "logs/flair/{sample}.bam2bed12.log"
    script:
        "../scripts/flair_bam2bed12.py"


rule flair_annotate:
    input:
        bed12="results/flair/{sample}/{sample}.bed12",
        gtf=GTF
    output:
        annotated_bed="results/flair/{sample}/{sample}.annotated.bed"
    conda:
        "../envs/flair.yaml"
    log:
        "logs/flair/{sample}.annotate.log"
    script:
        "../scripts/flair_annotate.py"


rule flair_collapse:
    input:
        annotated_bed="results/flair/{sample}/{sample}.annotated.bed",
        genome=FASTA,
        reads=clean_reads,
        gtf=GTF
    output:
        consensus="results/flair/{sample}/{sample}.flair.collapse.fasta"
    params:
        min_support=config["flair"].get("min_support", 3),
        end_window=config["flair"].get("end_window", 100),
        intpriming_threshold=config["flair"].get("intpriming_threshold", 30),
        trust_ends=config["flair"].get("trust_ends", True),
        remove_internal_priming=config["flair"].get("remove_internal_priming", True),
        stringent=config["flair"].get("stringent", True),
        check_splice=config["flair"].get("check_splice", True),
        quiet=config["flair"].get("quiet", True),
        mm2_args=config["flair"].get("mm2_args", "-I8g,--MD"),
        extra=config["flair"].get("collapse_extra", "")
    conda:
        "../envs/flair.yaml"
    log:
        "logs/flair/{sample}.collapse.log"
    threads:
        config["threads"]
    script:
        "../scripts/flair_collapse.py"
