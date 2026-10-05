rule gffcompare:
    input:
        merged="results/stringtie/merge/stringtie_merged.gtf",
        ref=GTF,
    output:
        annotated="results/gffcompare/nanoseq.annotated.gtf",
        tracking="results/gffcompare/nanoseq.tracking",
        loci="results/gffcompare/nanoseq.loci",
    log:
        "logs/gffcompare/gffcompare.log",
    conda:
        "../envs/gffcompare.yaml"
    params:
        extra=config["gffcompare"].get("extra_args", "-R -C -K -M"),
        prefix=lambda wildcards, output: output.annotated[: -len(".annotated.gtf")],
    script:
        "../scripts/gffcompare.py"


rule gffread_transcripts:
    input:
        gtf="results/stringtie/merge/stringtie_merged.gtf",
        fasta=FASTA,
    output:
        fasta="results/transcripts/merged_transcripts.fa",
    log:
        "logs/gffcompare/gffread.log",
    conda:
        "../envs/gffcompare.yaml"
    script:
        "../scripts/gffread.py"
