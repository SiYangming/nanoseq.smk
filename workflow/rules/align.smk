rule minimap2_align:
    input:
        reads=clean_reads,
        reference=FASTA
    output:
        bam="results/minimap2/{sample}/{sample}.bam",
        bai="results/minimap2/{sample}/{sample}.bam.bai",
        versions="results/minimap2/{sample}/{sample}.versions.yml"
    params:
        extra=config["minimap2"].get("args", "-ax splice -uf -k14"),
        cigar_bam=config["minimap2"].get("cigar_bam", False)
    conda:
        "../envs/minimap2.yaml"
    log:
        "logs/minimap2/{sample}.log"
    threads:
        config["threads"]
    script:
        "../scripts/minimap2_align.py"


rule bam_to_fastq:
    input:
        bam=aligned_bam
    output:
        fastq="results/qc/{sample}/{sample}.frombam.fastq.gz"
    conda:
        "../envs/minimap2.yaml"
    log:
        "logs/qc/{sample}.bam_to_fastq.log"
    threads:
        4
    script:
        "../scripts/samtools_fastq.py"


rule samtools_flagstat:
    input:
        bam=aligned_bam
    output:
        txt="results/align/{sample}/{sample}.flagstat.txt"
    conda:
        "../envs/minimap2.yaml"
    log:
        "logs/align/{sample}.flagstat.log"
    threads:
        2
    script:
        "../scripts/samtools_flagstat.py"
