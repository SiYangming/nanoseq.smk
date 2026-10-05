# fastp SE in the DRS DAG (Nanopore/Illumina FASTQ). PE standalone: fastp_pe.smk
#
# Chain: raw_reads → fastp_se → seqkit_qfilter → minimap2
# Skip when entrypoint is bam or run_fastp is false.

_fp = config.setdefault("fastp", {})
_fp.setdefault("docker_image", "")
_fp.setdefault("apptainer_image", "")
_fp.setdefault("fastp_bin", "fastp")
_fp.setdefault("adapter_sequence", "")
_fp.setdefault("detect_adapter_for_pe", False)
_fp.setdefault("qualified_quality_phred", None)
_fp.setdefault("unqualified_percent_limit", None)
_fp.setdefault("length_required", None)
_fp.setdefault("extra", "--disable_adapter_trimming")


rule fastp_se:
    input:
        fq1=raw_reads,
    output:
        out1="results/qc/{sample}/{sample}.fastp.fastq.gz",
        html="results/qc/{sample}/{sample}.fastp.html",
        json="results/qc/{sample}/{sample}.fastp.json",
    log:
        "logs/qc/{sample}.fastp.log",
    conda:
        "../envs/fastp.yaml"
    threads: config["threads"]
    params:
        adapter_sequence=_fp.get("adapter_sequence", ""),
        detect_adapter_for_pe=_fp.get("detect_adapter_for_pe", False),
        qualified_quality_phred=_fp.get("qualified_quality_phred"),
        unqualified_percent_limit=_fp.get("unqualified_percent_limit"),
        length_required=_fp.get("length_required"),
        extra=_fp.get("extra", ""),
    message:
        "fastp (SE): {input.fq1} -> {output.out1}"
    script:
        "../scripts/fastp.py"
