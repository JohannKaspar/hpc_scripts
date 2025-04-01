#!/bin/bash
#SBATCH --job-name=hyperparameter_tuning          # Job name
#SBATCH --output=/data/cephfs-1/home/users/joli13_c/logs/%x_%j.log      # Log file (%x = job name, %j = job ID)
#SBATCH --error=/data/cephfs-1/home/users/joli13_c/logs/%x_%j.err       # Error file (%x = job name, %j = job ID)
#SBATCH --mem=128G                                 # Memory allocation
#SBATCH --cpus-per-task=64                         # Number of CPU cores per task
#SBATCH --gres=gpu:tesla:4                        # Request 1 Tesla GPU
#SBATCH --partition=gpu                           # Specify the GPU partition
#SBATCH --time=1-00:00:00                         # Max time (1 day)
#SBATCH --mail-type=BEGIN,END,FAIL                # Send email on start, end, and fail
#SBATCH --mail-user=johann-kaspar.lieberwirth@charite.de   # Email for notifications

# Load modules if needed (e.g., CUDA modules for GPU support)
# module load cuda/11.3    # Example: load the CUDA module if required by the script

# Activate the Conda environment
source ~/.bashrc             # Ensure access to Conda command
conda activate voice_biomarker

tensorboard --logdir="~/voice_biomarker/runs/" --port=6006 &
#echo "Node: $(hostname) Port: 6006"

# Run the training script
srun python ~/voice_biomarker/hyperparameter_tuning.py "$@"
