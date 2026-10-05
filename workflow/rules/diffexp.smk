rule edger_coldata:
    output:
        tsv="results/edger/coldata.tsv",
    log:
        "logs/edger/coldata.log",
    conda:
        "../envs/python.yaml"
    params:
        rows=lambda wildcards: [
            (sample, sample_condition(sample) or "NA") for sample in SAMPLE_IDS
        ],
    script:
        "../scripts/write_edger_coldata.py"


rule edger_de:
    input:
        counts="results/quant/transcript_counts.tsv",
        coldata="results/edger/coldata.tsv",
    output:
        table="results/edger/de_transcripts.tsv",
    log:
        "logs/edger/analyze.log",
    conda:
        "../envs/edger.yaml"
    params:
        pair=config.get("edger", {}).get("pair", ""),
        cpm_cutoff=config.get("edger", {}).get("cpm_cutoff", 1),
        min_samples=config.get("edger", {}).get("min_samples", 1),
        adjust=config.get("edger", {}).get("adjust", "BH"),
    script:
        "../scripts/run_edger.py"
