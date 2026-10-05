#!/usr/bin/env bash
# nanoseq.smk runner — exec_mode from config: native | conda | docker | apptainer
set -euo pipefail

SNAKEMAKE_CMD="snakemake"
WORKDIR="."
PASSTHRU=()

while [[ $# -gt 0 ]]; do
    case "$1" in
        --directory|-d)
            WORKDIR="$2"
            shift 2
            ;;
        --directory=*|-d=*)
            WORKDIR="${1#*=}"
            shift
            ;;
        --resume)
            PASSTHRU+=(--rerun-incomplete)
            shift
            ;;
        *)
            PASSTHRU+=("$1")
            shift
            ;;
    esac
done

if [[ -f "$WORKDIR/workflow/Snakefile" ]]; then
    SNAKEFILE="$WORKDIR/workflow/Snakefile"
elif [[ -f "workflow/Snakefile" ]]; then
    SNAKEFILE="workflow/Snakefile"
elif [[ -f "$WORKDIR/Snakefile" ]]; then
    SNAKEFILE="$WORKDIR/Snakefile"
else
    echo "[ERROR] Snakefile not found" >&2
    exit 1
fi

if [[ -f "$WORKDIR/config/config.yaml" ]]; then
    CONFIG="$WORKDIR/config/config.yaml"
elif [[ -f "config/config.yaml" ]]; then
    CONFIG="config/config.yaml"
else
    echo "[ERROR] config.yaml not found" >&2
    exit 1
fi

EXEC_MODE=$(grep -E '^exec_mode:' "$CONFIG" | head -n 1 | sed -E 's/.*:[[:space:]]*"?([^"]*)"?.*/\1/')
EXEC_MODE="${EXEC_MODE:-conda}"
echo "Working directory: $WORKDIR"
echo "Snakefile: $SNAKEFILE | Config: $CONFIG | exec_mode=$EXEC_MODE"

SNAKEMAKE_OPTS=()
case "$EXEC_MODE" in
    native)    : ;;
    conda)     SNAKEMAKE_OPTS+=(--use-conda) ;;
    docker)    : ;;
    apptainer) : ;;
    *)
        echo "[ERROR] unknown exec_mode: $EXEC_MODE (native|conda|docker|apptainer)" >&2
        exit 1
        ;;
esac

$SNAKEMAKE_CMD -s "$SNAKEFILE" \
    --configfile "$CONFIG" \
    --directory "$WORKDIR" \
    -c all -p \
    --latency-wait 60 \
    "${SNAKEMAKE_OPTS[@]}" \
    "${PASSTHRU[@]}"
