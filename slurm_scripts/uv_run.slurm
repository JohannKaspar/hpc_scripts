#!/bin/bash
#SBATCH --job-name=uv_run_main                  # Job name
#SBATCH --output=/data/cephfs-1/home/users/joli13_c/work/logs/%x_%j.log  # Log file
#SBATCH --error=/data/cephfs-1/home/users/joli13_c/work/logs/%x_%j.err   # Error file
# #SBATCH --mem=64G                               # Memory allocation
# #SBATCH --cpus-per-task=16                       # Number of CPU cores per task
#SBATCH --time=16:00:00                       
#SBATCH --mail-type=BEGIN,END,FAIL              # Send email on start, end, and fail
#SBATCH --mail-user=johann-kaspar.lieberwirth@charite.de   # Email for notifications

# Change to the working directory
cd ~/voice_biomarker || exit 1

# Run the script using uv
srun uv run "$@"
