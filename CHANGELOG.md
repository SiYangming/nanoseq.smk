# Changelog

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
