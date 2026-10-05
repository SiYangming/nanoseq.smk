"""Write edgeR colData from the sample sheet conditions."""

from pathlib import Path

out = Path(snakemake.output.tsv)
out.parent.mkdir(parents=True, exist_ok=True)
lines = ["sample\tcondition\n"]
for sample, condition in snakemake.params.rows:
    lines.append(f"{sample}\t{condition}\n")
out.write_text("".join(lines))
