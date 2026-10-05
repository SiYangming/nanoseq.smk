rule stringtie_assemble:
    input:
        bam=aligned_bam,
    output:
        gtf="results/stringtie/assemble/{sample}.stringtie.gtf",
    log:
        "logs/stringtie/{sample}.assemble.log",
    conda:
        "../envs/stringtie.yaml"
    threads: config["threads"]
    params:
        flags="--conservative -L -R",
        gtf_arg=lambda wc: f"-G {GTF}" if GTF else "",
        label=lambda wc: wc.sample,
        min_len=config["stringtie"].get("min_transcript_len", 200),
        extra=config["stringtie"].get("extra_args", ""),
    script:
        "../scripts/stringtie_assemble.py"


rule stringtie_fix_gtf:
    input:
        gtf="results/stringtie/assemble/{sample}.stringtie.gtf",
    output:
        fixed_gtf="results/stringtie/assemble/{sample}.stringtie.fixed.gtf",
    log:
        "logs/stringtie/{sample}.fix_gtf.log",
    conda:
        "../envs/python.yaml"
    script:
        "../scripts/stringtie_fix_gtf.py"


rule stringtie_gtf_list:
    input:
        gtfs=expand(
            "results/stringtie/assemble/{sample}.stringtie.fixed.gtf",
            sample=SAMPLE_IDS,
        ),
    output:
        gtf_list="results/stringtie/merge/gtf_list.txt",
    log:
        "logs/stringtie/gtf_list.log",
    conda:
        "../envs/python.yaml"
    script:
        "../scripts/write_gtf_list.py"


rule stringtie_merge:
    input:
        gtf_list="results/stringtie/merge/gtf_list.txt",
        gtfs=expand(
            "results/stringtie/assemble/{sample}.stringtie.fixed.gtf",
            sample=SAMPLE_IDS,
        ),
    output:
        merged_gtf="results/stringtie/merge/stringtie_merged.gtf",
    log:
        "logs/stringtie/merge.log",
    conda:
        "../envs/stringtie.yaml"
    threads: config["threads"]
    params:
        gtf_arg=lambda wc: f"-G {GTF}" if GTF else "",
        label=config["stringtie"].get("merge_label", "MSTRG"),
        min_len=config["stringtie"].get("min_transcript_len", 200),
        extra=config["stringtie"].get("extra_args", ""),
    script:
        "../scripts/stringtie_merge.py"
