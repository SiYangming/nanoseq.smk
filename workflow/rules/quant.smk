import os


rule salmon_index:
    input:
        transcripts="results/transcripts/merged_transcripts.fa",
    output:
        idx=directory("results/salmon/index"),
    log:
        "logs/salmon/index.log",
    conda:
        "../envs/salmon.yaml"
    threads: config["threads"]
    params:
        kmer=config["salmon"].get("kmer", 31),
        extra=config["salmon"].get("extra_args", ""),
    script:
        "../scripts/salmon_index.py"


rule salmon_quant:
    input:
        index="results/salmon/index",
        reads=clean_reads,
    output:
        quant="results/salmon/{sample}/quant.sf",
    log:
        "logs/salmon/{sample}.quant.log",
    conda:
        "../envs/salmon.yaml"
    threads: config["threads"]
    params:
        outdir=lambda wildcards, output: os.path.dirname(output.quant),
        libtype=config["salmon"].get("libtype", "A"),
        extra=config["salmon"].get("extra_args", ""),
    script:
        "../scripts/salmon_quant.py"


rule merge_salmon:
    input:
        quants=expand("results/salmon/{sample}/quant.sf", sample=SAMPLE_IDS),
    output:
        counts="results/quant/transcript_counts.tsv",
        tpm="results/quant/transcript_tpm.tsv",
    log:
        "logs/quant/merge_salmon.log",
    conda:
        "../envs/python.yaml"
    params:
        samples=SAMPLE_IDS,
    script:
        "../scripts/merge_salmon.py"
