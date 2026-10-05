rule stringtie_assemble:
    input:
        bam=aligned_bam
    output:
        gtf="results/stringtie/assemble/{sample}.stringtie.gtf"
    params:
        flags="--conservative -L -R",
        gtf_arg=lambda wc: f"-G {GTF}" if GTF else "",
        label=lambda wc: wc.sample,
        min_len=config["stringtie"].get("min_transcript_len", 200),
        extra=config["stringtie"].get("extra_args", "")
    conda:
        "../envs/stringtie.yaml"
    log:
        "logs/stringtie/{sample}.assemble.log"
    threads:
        config["threads"]
    script:
        "../scripts/stringtie_assemble.py"


rule stringtie_fix_gtf:
    input:
        gtf="results/stringtie/assemble/{sample}.stringtie.gtf"
    output:
        fixed_gtf="results/stringtie/assemble/{sample}.stringtie.fixed.gtf"
    log:
        "logs/stringtie/{sample}.fix_gtf.log"
    script:
        "../scripts/stringtie_fix_gtf.py"


rule stringtie_gtf_list:
    input:
        gtfs=expand(
            "results/stringtie/assemble/{sample}.stringtie.fixed.gtf",
            sample=SAMPLE_IDS,
        )
    output:
        gtf_list="results/stringtie/merge/gtf_list.txt"
    log:
        "logs/stringtie/gtf_list.log"
    run:
        with open(output.gtf_list, "w") as fh:
            for path in input.gtfs:
                fh.write(f"{path}\n")


rule stringtie_merge:
    input:
        gtf_list="results/stringtie/merge/gtf_list.txt"
    output:
        merged_gtf="results/stringtie/merge/stringtie_merged.gtf"
    params:
        gtf_arg=lambda wc: f"-G {GTF}" if GTF else "",
        label=config["stringtie"].get("merge_label", "MSTRG"),
        min_len=config["stringtie"].get("min_transcript_len", 200),
        extra=config["stringtie"].get("extra_args", "")
    conda:
        "../envs/stringtie.yaml"
    log:
        "logs/stringtie/merge.log"
    threads:
        config["threads"]
    script:
        "../scripts/stringtie_merge.py"
