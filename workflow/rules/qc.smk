rule seqkit_stats:
    input:
        reads=lambda wc: raw_reads(wc) if ENTRY != "bam" else clean_reads(wc)
    output:
        tsv="results/qc/{sample}/{sample}.seqkit.stats.tsv"
    conda:
        "../envs/seqkit.yaml"
    log:
        "logs/qc/{sample}.seqkit.stats.log"
    threads:
        config["threads"]
    script:
        "../scripts/seqkit_stats.py"


rule seqkit_qfilter:
    input:
        reads=raw_reads
    output:
        fastq="results/qc/{sample}/{sample}.q{qscore}.fastq.gz"
    params:
        min_q=lambda wc: int(wc.qscore)
    conda:
        "../envs/seqkit.yaml"
    log:
        "logs/qc/{sample}.q{qscore}.log"
    threads:
        config["threads"]
    wildcard_constraints:
        qscore="[0-9]+"
    script:
        "../scripts/seqkit_qfilter.py"
