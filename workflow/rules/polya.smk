import os


rule extract_polya_bed:
    input:
        bam=aligned_bam,
    output:
        bed="results/polya/beds/{sample}.bed",
    log:
        "logs/polya/{sample}.bed.log",
    conda:
        "../envs/minimap2.yaml"
    script:
        "../scripts/extract_polya_bed.py"


rule quantifypolya:
    input:
        beds=expand("results/polya/beds/{sample}.bed", sample=SAMPLE_IDS),
        fasta=FASTA,
        gtf=GTF,
    output:
        sites="results/polya/polyA_sites.tsv",
    log:
        "logs/polya/quantifypolya.log",
    conda:
        "../envs/quantifypolya.yaml"
    threads: config["threads"]
    params:
        bed_dir=lambda wildcards, input: os.path.dirname(input.beds[0]),
        outdir=lambda wildcards, output: os.path.dirname(output.sites),
        max_gapwidth=config.get("quantifypolya", {}).get("max_gapwidth", 24),
        quant_mode=config.get("quantifypolya", {}).get("quant_mode", "canonical"),
    script:
        "../scripts/quantifypolya.py"
