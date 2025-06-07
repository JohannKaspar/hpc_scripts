#!/bin/bash
#SBATCH --job-name=uv_run_main
#SBATCH --output=/data/cephfs-1/home/users/joli13_c/work/logs/%x_%j.log
#SBATCH --error=/data/cephfs-1/home/users/joli13_c/work/logs/%x_%j.err
#SBATCH --time=16:00:00
#SBATCH --mail-type=BEGIN,END,FAIL
#SBATCH --mail-user=johann-kaspar.lieberwirth@charite.de

# First argument is the script name (e.g. "embed.py")
SCRIPT_NAME="$1"
shift

# Determine project folder by using the current working directory’s basename.
# When you submit from ~/guideline_rag, $PWD will be /home/users/joli13_c/guideline_rag,
# so PROJECT_DIR="guideline_rag"
PROJECT_DIR="$(basename "$PWD")"

# cd into ~/PROJECT_DIR
cd "$HOME/$PROJECT_DIR" || exit 1

# Run the script with uv, passing along any extra arguments
uv run "$SCRIPT_NAME" "$@"