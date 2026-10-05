rule extract_polya_bed:
    input:
        bam=aligned_bam
    output:
        bed="results/polya/beds/{sample}.bed"
    conda:
        "../envs/minimap2.yaml"
    log:
        "logs/polya/{sample}.bed.log"
    script:
        "../scripts/extract_polya_bed.py"


rule quantifypolya:
    input:
        beds=expand("results/polya/beds/{sample}.bed", sample=SAMPLE_IDS),
        fasta=FASTA,
        gtf=GTF
    output:
        sites="results/polya/polyA_sites.tsv"
    params:
        bed_dir="results/polya/beds",
        outdir="results/polya",
        max_gapwidth=config.get("quantifypolya", {}).get("max_gapwidth", 24),
        quant_mode=config.get("quantifypolya", {}).get("quant_mode", "canonical")
    conda:
        "../envs/quantifypolya.yaml"
    log:
        "logs/polya/quantifypolya.log"
    threads:
        config["threads"]
    script:
        "../scripts/quantifypolya.py"
