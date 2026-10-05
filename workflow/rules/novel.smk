rule gffcompare:
    input:
        merged="results/stringtie/merge/stringtie_merged.gtf",
        ref=GTF
    output:
        annotated="results/gffcompare/nanoseq.annotated.gtf",
        tracking="results/gffcompare/nanoseq.tracking",
        loci="results/gffcompare/nanoseq.loci"
    params:
        extra=config["gffcompare"].get("extra_args", "-R -C -K -M"),
        prefix="results/gffcompare/nanoseq"
    conda:
        "../envs/gffcompare.yaml"
    log:
        "logs/gffcompare/gffcompare.log"
    script:
        "../scripts/gffcompare.py"


rule gffread_transcripts:
    input:
        gtf="results/stringtie/merge/stringtie_merged.gtf",
        fasta=FASTA
    output:
        fasta="results/transcripts/merged_transcripts.fa"
    conda:
        "../envs/gffcompare.yaml"
    log:
        "logs/gffcompare/gffread.log"
    script:
        "../scripts/gffread.py"
