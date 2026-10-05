rule salmon_index:
    input:
        transcripts="results/transcripts/merged_transcripts.fa"
    output:
        idx=directory("results/salmon/index")
    params:
        kmer=config["salmon"].get("kmer", 31),
        extra=config["salmon"].get("extra_args", "")
    conda:
        "../envs/salmon.yaml"
    log:
        "logs/salmon/index.log"
    threads:
        config["threads"]
    script:
        "../scripts/salmon_index.py"


rule salmon_quant:
    input:
        index="results/salmon/index",
        reads=clean_reads
    output:
        quant="results/salmon/{sample}/quant.sf"
    params:
        outdir="results/salmon/{sample}",
        libtype=config["salmon"].get("libtype", "A"),
        extra=config["salmon"].get("extra_args", "")
    conda:
        "../envs/salmon.yaml"
    log:
        "logs/salmon/{sample}.quant.log"
    threads:
        config["threads"]
    script:
        "../scripts/salmon_quant.py"


rule merge_salmon:
    input:
        quants=expand("results/salmon/{sample}/quant.sf", sample=SAMPLE_IDS)
    output:
        counts="results/quant/transcript_counts.tsv",
        tpm="results/quant/transcript_tpm.tsv"
    params:
        samples=SAMPLE_IDS
    log:
        "logs/quant/merge_salmon.log"
    script:
        "../scripts/merge_salmon.py"
