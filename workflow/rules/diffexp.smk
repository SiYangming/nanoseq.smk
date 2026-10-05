rule edger_coldata:
    output:
        tsv="results/edger/coldata.tsv"
    log:
        "logs/edger/coldata.log"
    run:
        with open(output.tsv, "w") as fh:
            fh.write("sample\tcondition\n")
            for sample in SAMPLE_IDS:
                cond = sample_condition(sample) or "NA"
                fh.write(f"{sample}\t{cond}\n")


rule edger_de:
    input:
        counts="results/quant/transcript_counts.tsv",
        coldata="results/edger/coldata.tsv"
    output:
        table="results/edger/de_transcripts.tsv"
    params:
        pair=config.get("edger", {}).get("pair", ""),
        cpm_cutoff=config.get("edger", {}).get("cpm_cutoff", 1),
        min_samples=config.get("edger", {}).get("min_samples", 1),
        adjust=config.get("edger", {}).get("adjust", "BH")
    conda:
        "../envs/edger.yaml"
    log:
        "logs/edger/analyze.log"
    script:
        "../scripts/run_edger.py"
