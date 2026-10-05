"""GTF coordinate fix $4<=$5 (bioskills modules/stringtie)."""

from __future__ import annotations

from pathlib import Path

from snakemake.shell import shell

_awk = Path(__file__).resolve().parent / "fix_gtf.awk"
_log = snakemake.log_fmt_shell(stdout=False, stderr=True)

shell(
    f'awk -F "\\t" -v OFS="\\t" -f "{_awk}" '
    f'"{snakemake.input.gtf}" > "{snakemake.output.fixed_gtf}" {_log}'
)
