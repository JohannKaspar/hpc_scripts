#!/bin/bash
#SBATCH --output=/data/cephfs-1/home/users/joli13_c/logs/%x_%j.log      # Log file (%x = job name, %j = job ID)
#SBATCH --error=/data/cephfs-1/home/users/joli13_c/logs/%x_%j.err       # Error file (%x = job name, %j = job ID)
#SBATCH --mem=64G                                  # Memory allocation
#SBATCH --cpus-per-task=16                         # Number of CPU cores per task
#SBATCH --gres=gpu:tesla:1                         # Request 1 Tesla GPU
#SBATCH --partition=gpu                            # Specify the GPU partition
#SBATCH --time=1-00:00:00                          # Max time (1 day)
#SBATCH --mail-type=BEGIN,END,FAIL                 # Send email on start, end, and fail
#SBATCH --mail-user=johann-kaspar.lieberwirth@charite.de   # Email for notifications

# Check if a job name is provided as an environment variable
if [ -z "$JOB_NAME" ]; then
    export JOB_NAME="default_job_name"
fi

#SBATCH --job-name=${JOB_NAME}                     # Use the job name provided or default

# Navigate to the working directory
cd /data/cephfs-1/home/users/joli13_c/test_vb || exit

# Activate the virtual environment
source .venv/bin/activate

# Run the provided script with arguments
srun python "$@"
