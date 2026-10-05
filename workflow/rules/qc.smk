rule seqkit_stats:
    input:
        reads=lambda wc: raw_reads(wc) if ENTRY != "bam" else clean_reads(wc),
    output:
        tsv="results/qc/{sample}/{sample}.seqkit.stats.tsv",
    log:
        "logs/qc/{sample}.seqkit.stats.log",
    conda:
        "../envs/seqkit.yaml"
    threads: config["threads"]
    script:
        "../scripts/seqkit_stats.py"


rule seqkit_qfilter:
    input:
        reads=raw_reads,
    output:
        fastq="results/qc/{sample}/{sample}.q{qscore}.fastq.gz",
    log:
        "logs/qc/{sample}.q{qscore}.log",
    wildcard_constraints:
        qscore="[0-9]+",
    conda:
        "../envs/seqkit.yaml"
    threads: config["threads"]
    params:
        min_q=lambda wc: int(wc.qscore),
    script:
        "../scripts/seqkit_qfilter.py"
