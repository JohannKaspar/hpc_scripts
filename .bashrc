# .bashrc

# Source global definitions
if [ -f /etc/bashrc ]; then
	. /etc/bashrc
fi

# Uncomment the following line if you don't like systemctl's auto-paging feature:
# export SYSTEMD_PAGER=

# User specific aliases and functions

# >>> conda initialize >>>
# !! Contents within this block are managed by 'conda init' !!
__conda_setup="$('/data/cephfs-1/work/groups/mittermaier/users/joli13_c/miniforge/bin/conda' 'shell.bash' 'hook' 2> /dev/null)"
if [ $? -eq 0 ]; then
    eval "$__conda_setup"
else
    if [ -f "/data/cephfs-1/work/groups/mittermaier/users/joli13_c/miniforge/etc/profile.d/conda.sh" ]; then
        . "/data/cephfs-1/work/groups/mittermaier/users/joli13_c/miniforge/etc/profile.d/conda.sh"
    else
        export PATH="/data/cephfs-1/work/groups/mittermaier/users/joli13_c/miniforge/bin:$PATH"
    fi
fi
unset __conda_setup

if [ -f "/data/cephfs-1/work/groups/mittermaier/users/joli13_c/miniforge/etc/profile.d/mamba.sh" ]; then
    . "/data/cephfs-1/work/groups/mittermaier/users/joli13_c/miniforge/etc/profile.d/mamba.sh"
fi
# <<< conda initialize <<<

#alias srun_std="srun --time=12:00:00 --mem=16G --cpus-per-task=16 --pty bash -i"
#alias srun_std64="srun --time=12:00:00 --mem=64G --cpus-per-task=64 --pty bash -i"
alias srun_gpu="srun --mem=16G --cpus-per-task=16 --gres=gpu:tesla:1 -p gpu --time=12:00:00 --pty bash -i"
alias start_jup="~/scripts/start_jupyter.sh"
alias train_model="sbatch ~/slurm_scripts/train_voice_model.sbatch"
alias tune_hyperparam="sbatch ~/slurm_scripts/hyper_parameter_tuning.sbatch"
alias debug_hyper="sbatch ~/slurm_scripts/debug_hyper.sbatch  --num_experiments 5 --num_data_samples 2560 --epochs 5 --grace_period 2"

alias latest_log='cat $(ls -t ~/work/logs/*.log | head -n 1)'
alias latest_err='cat $(ls -t ~/work/logs/*.err | head -n 1)'
alias vb='cd ~/voice_biomarker'
alias wav2vec='cd ~/voice_biomarker/experiments/wav2vec2'
alias watch_log='tail -f $(ls -t ~/work/logs/*.log | head -n 1)'
alias watch_err='tail -f $(ls -t ~/work/logs/*.err | head -n 1)'

alias activate="source ~/work/.venv_voice_biomarker_new/bin/activate"
alias workon_vb="cd ~/voice_biomarker && activate"
alias sync_aufnahmen="~/scripts/sync_aufnahmen.sh"
alias group_work="cd /data/cephfs-1/work/groups/mittermaier"
#alias uv_run_slurm="sbatch ~/slurm_scripts/uv_run.slurm"
#alias uv_run_slurm64="sbatch ~/slurm_scripts/uv_run64.slurm"
alias train="uv run src/train.py"
alias upload="~/scripts/upload_outputs.sh"
alias config='git --git-dir=$HOME/.cfg.git/ --work-tree=$HOME'

export PATH=$PATH:~/bin:~/scripts
export UV_PROJECT_ENVIRONMENT="/data/cephfs-1/home/users/joli13_c/work/.venv_voice_biomarker_new"
export PATH=/data/cephfs-1/work/groups/mittermaier/users/joli13_c/miniforge/bin:$PATH
export PYTHONPATH="/data/cephfs-1/home/users/joli13_c/voice_biomarker:$PYTHONPATH"

function stimmaufnahmen {
    base_dir="/data/cephfs-1/work/groups/mittermaier/stimmaufnahmen"
    if [[ ! -d "$base_dir" ]]; then
        echo "Directory $base_dir does not exist."
        return 1
    fi
    latest_dir=$(ls -d "$base_dir"/20[0-9][0-9]-[01][0-9]-[0-3][0-9] 2>/dev/null | sort -r | head -n 1)
    if [[ -z "$latest_dir" ]]; then
        echo "No valid timestamped directories found in $base_dir."
        return 1
    fi
    cd "$latest_dir" || return 1
    echo "Changed directory to $latest_dir"
}

_rw_completions() {
    local cur base_dir file candidate
    cur="${COMP_WORDS[COMP_CWORD]}"
    base_dir="$HOME/voice_biomarker/src/"
    local IFS=$'\n'
    COMPREPLY=()
    for file in $(compgen -f -- "$base_dir$cur"); do
         # Remove the base directory from the candidate
         candidate="${file#$base_dir}"
         # If it's a directory, append a slash
         if [ -d "$file" ]; then
             candidate="${candidate}/"
         fi
         COMPREPLY+=("$candidate")
    done
}
complete -F _rw_completions -o nospace rw

uv_slurm() {
    # Print usage info
    usage() {
        echo "Usage: uv_slurm [MEM] [CPUS] SCRIPT [ARGS...]"
        echo "  MEM   - memory (e.g., 32G), default: 64G"
        echo "  CPUS  - number of CPU cores (e.g., 8), default: 16"
        echo "  SCRIPT - path to Python script (e.g., src/train.py)"
        echo "  ARGS  - additional arguments passed to uv run"
    }

    # Check if first argument looks like memory (ends with G or M)
    if [[ "$1" =~ ^[0-9]+[GM]$ ]]; then
        MEM=$1
        shift
    else
        MEM=64G
    fi

    # Check if next argument looks like an integer (CPU count)
    if [[ "$1" =~ ^[0-9]+$ ]]; then
        CPUS=$1
        shift
    else
        CPUS=16
    fi

    # Check if script argument is present
    if [[ -z "$1" ]]; then
        echo "Error: No script specified."
        usage
        return 1
    fi

    # Submit the job
    echo "Submitting SLURM job with:"
    echo "  Memory:         $MEM"
    echo "  CPUs per task:  $CPUS"
    echo "  Script:         $1"
    echo "  Additional args: ${*:2}"

    sbatch --mem="$MEM" --cpus-per-task="$CPUS" ~/slurm_scripts/uv_run.slurm "$@"
}

srun_std() {
    # Print usage info
    usage() {
        echo "Usage: srun_std [MEM] [CPUS]"
        echo "  MEM   - memory (e.g., 32G), default: 16G"
        echo "  CPUS  - number of CPU cores (e.g., 8), default: 16"
    }

    # Check if first argument looks like memory (ends with G or M)
    if [[ "$1" =~ ^[0-9]+[GM]$ ]]; then
        MEM=$1
        shift
    else
        MEM=16G
    fi

    # Check if next argument looks like an integer (CPU count)
    if [[ "$1" =~ ^[0-9]+$ ]]; then
        CPUS=$1
        shift
    else
        CPUS=16
    fi

    # Submit the job
    echo "Submitting SLURM job with:"
    echo "  Memory:         $MEM"
    echo "  CPUs per task:  $CPUS"

    srun --time=12:00:00 --mem="$MEM" --cpus-per-task="$CPUS" --pty bash -i
}
