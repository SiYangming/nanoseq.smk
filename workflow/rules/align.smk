rule minimap2_align:
    input:
        reads=clean_reads,
        reference=FASTA,
    output:
        bam="results/minimap2/{sample}/{sample}.bam",
        bai="results/minimap2/{sample}/{sample}.bam.bai",
        versions="results/minimap2/{sample}/{sample}.versions.yml",
    log:
        "logs/minimap2/{sample}.log",
    conda:
        "../envs/minimap2.yaml"
    threads: config["threads"]
    params:
        extra=config["minimap2"].get("args", "-ax splice -uf -k14"),
        cigar_bam=config["minimap2"].get("cigar_bam", False),
    script:
        "../scripts/minimap2_align.py"


rule bam_to_fastq:
    input:
        bam=aligned_bam,
    output:
        fastq="results/qc/{sample}/{sample}.frombam.fastq.gz",
    log:
        "logs/qc/{sample}.bam_to_fastq.log",
    conda:
        "../envs/minimap2.yaml"
    threads: 4
    script:
        "../scripts/samtools_fastq.py"


rule samtools_flagstat:
    input:
        bam=aligned_bam,
    output:
        txt="results/align/{sample}/{sample}.flagstat.txt",
    log:
        "logs/align/{sample}.flagstat.log",
    conda:
        "../envs/minimap2.yaml"
    threads: 2
    script:
        "../scripts/samtools_flagstat.py"
