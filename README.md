# Snakemake workflow: `nanoseq.smk`

[![Snakemake](https://img.shields.io/badge/snakemake-≥8.0.0-brightgreen.svg)](https://snakemake.github.io)
[![run with conda](http://img.shields.io/badge/run%20with-conda-3EB049?labelColor=000000&logo=anaconda)](https://docs.conda.io/en/latest/)

Nanopore Direct RNA-seq (DRS) analysis matching the Benagen DRS report logic,
assembled from [bioskills](https://github.com/SiYangming/bioskills) module wrappers
(same layout as [isoseq.smk](https://github.com/SiYangming/isoseq.smk)).

## Pipeline

1. Optional Dorado basecall (`pod5`/`fast5`, `--estimate-poly-a`)
2. `fastp` SE QC (`run_fastp`, default on; adapter trim off for ONT)
3. Pass reads Q ≥ 10 (`seqkit seq -Q 10`)
4. Align: `minimap2 -ax splice -uf -k14` + `samtools flagstat`
5. Consensus isoforms: FLAIR `bam2bed12` → `identify_gene_isoform` → `collapse`
6. Reconstruct / collapse: StringTie `--conservative -L -R` then `--merge`
7. Novel transcripts: `gffcompare -R -C -K -M` (no ORF/CDS prediction)
8. Quantify: salmon TPM
9. Differential expression: edgeR (when `condition` is in the sample sheet)
10. Optional poly(A) sites: BAM 3′ ends → QuantifyPolyA (`run_polya: true`)

ORF-related steps are **not** included: TransDecoder, ORFfinder, ORFanage, TD2,
and protein-level diamond/hmmscan annotation that depends on predicted CDS.

Illumina `fastp` PE rules remain at `workflow/rules/fastp_pe.smk` (not in the DRS DAG).

Not yet wrapped from bioskills (report mentions them): AGAT UTR extension, SUPPA2,
FusionSeeker, CNCI/CPC2/PLEK lncRNA, Dorado/modkit m6A, clusterProfiler/GSEA.

## Usage

```bash
bash .test/fetch_testdata.sh
bash run_smk.sh --directory .test --cores 2
```

`exec_mode` in `config/config.yaml`: `native` | `conda` | `docker` | `apptainer`.

`entrypoint`: `pod5` | `fastq` | `bam`.

## Authors

- Yangming Si

## References

> Köster, J. et al. _Sustainable data analysis with Snakemake_. F1000Research, 2021.
