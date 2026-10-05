# Changelog

## Unreleased

### Added

- Illumina `fastp` SE/PE Snakemake wrappers from bioskills (`workflow/rules/fastp_{se,pe}.smk` standalone PE;
  `workflow/rules/fastp.smk` SE is **in the DRS DAG**: raw FASTQ → fastp → seqkit Q-filter).
  Disable with `run_fastp: false`. Default extra `--disable_adapter_trimming` (ONT DRS).

## [1.1.0](https://github.com/SiYangming/nanoseq.smk/compare/v1.0.0...v1.1.0) (2026-10-05)


### Features

* add fastp SE QC to the DRS DAG ([4154d0e](https://github.com/SiYangming/nanoseq.smk/commit/4154d0e23dcf7ce8ec50b4cc225f9943cf93c702))

## [1.0.0] - 2026-10-05

### Added

- Nanopore Direct RNA-seq Snakemake workflow aligned to the Benagen DRS report:
  Dorado (optional) → Q10 filter → minimap2 → FLAIR consensus → StringTie merge
  → gffcompare novel transcripts → salmon TPM → edgeR.
- Poly(A) site clustering via QuantifyPolyA is optional (`run_polya`).
- ORF / CDS prediction (TransDecoder, ORFfinder, ORFanage, TD2) is intentionally omitted.

### Fixed

- Snakemake lint/format, FLAIR conda pins, wrapper `__future__` imports, and CI `--all-temp` GTF retention.
- FLAIR `--mm2_args` argparse, gffcompare `combined.gtf` delivery, and edgeR no-replicate dispersion.
