"""Write a one-path-per-line GTF list for stringtie --merge."""

from pathlib import Path

out = Path(snakemake.output.gtf_list)
out.parent.mkdir(parents=True, exist_ok=True)
out.write_text("".join(f"{path}\n" for path in snakemake.input.gtfs))
