## Workflow overview

Nanopore Direct RNA-seq following the Benagen DRS report (no ORF/CDS prediction).

## Input data

Sample sheet (`config/samples.tsv`):

| sample | pod5 | reads | bam | condition |
| ------ | ---- | ----- | --- | --------- |
| A1     | optional POD5/FAST5 dir | FASTQ for `fastq` | aligned BAM for `bam` | group for edgeR |

Set `fasta` and `gtf` in `config/config.yaml`.

`entrypoint`:

- `pod5`: Dorado basecall then Q-filter and mapping
- `fastq`: start from `reads`
- `bam`: start from aligned `bam` (skip minimap2)

Tiny self-contained test files: `bash .test/fetch_testdata.sh`.
