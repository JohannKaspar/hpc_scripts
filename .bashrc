# .bashrc

# Source global definitions
if [ -f /etc/bashrc ]; then
        . /etc/bashrc
fi

# Uncomment the following line if you don't like systemctl's auto-paging feature:
# export SYSTEMD_PAGER=

# User specific aliases and functions
alias srun_gpu="srun --mem=16G --cpus-per-task=16 --gres=gpu:tesla:1 -p gpu --time=12:00:00 --pty bash -i"
alias start_jup="~/scripts/start_jupyter.sh"

alias latest_log='cat $(ls -t ~/work/logs/*.log | head -n 1)'
alias latest_err='cat $(ls -t ~/work/logs/*.err | head -n 1)'
alias vb='cd ~/voice_biomarker'
alias watch_log='tail -f $(ls -t ~/work/logs/*.log | head -n 1)'
alias watch_err='tail -f $(ls -t ~/work/logs/*.err | head -n 1)'
alias activate="source ~/work/uv_envs/voice_biomarker/bin/activate"
alias sync_aufnahmen="~/scripts/sync_aufnahmen.sh"
alias group_work="cd /data/cephfs-1/work/groups/mittermaier"
alias train="uv run src/train.py"
alias upload="~/scripts/upload_outputs.sh"
alias config='git --git-dir=$HOME/.cfg.git/ --work-tree=$HOME'

export PATH=$PATH:~/bin:~/scripts
export UV_PROJECT_ENVIRONMENT="/data/cephfs-1/home/users/joli13_c/work/uv_envs/voice_biomarker"
export PYTHONPATH="/data/cephfs-1/home/users/joli13_c/voice_biomarker:$PYTHONPATH"

function stimmaufnahmen {
    base_dir="/data/cephfs-1/work/groups/mittermaier/stimmaufnahmen"
    if [[ ! -d "$base_dir" ]]; then
        echo "Directory $base_dir does not exist."
        return 1
    fi
    # latest_dates=($(ls -d 202* | sort -r | head -n 2))

    latest_dir=$(ls -d "$base_dir"/* 2>/dev/null | sort -r | head -n 1)
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
    base_dir="$HOME/voice_biomarker/"
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
    # Usage-Info
    usage() {
        echo "Usage: uv_slurm [TIME] [MEM] [CPUS] [GPUS] SCRIPT [ARGS...]"
        echo "  TIME   – Laufzeit (z. B. 12:00:00), default: 12:00:00"
        echo "  MEM    – memory (z. B. 32G), default: 32G"
        echo "  CPUS   – CPU cores, default: 16"
        echo "  GPUS   – GPUs, default: 0"
        echo "  SCRIPT – Pfad zum Python-Script"
        echo "  ARGS   – zusätzliche Argumente"
    }

    # 1) TIME
    if [[ "$1" =~ ^([0-9]+:)?[0-9]{1,2}:[0-9]{2}(:[0-9]{2})?$ ]]; then
        TIME="$1"; shift
    else
        TIME="12:00:00"
    fi

    # 2) MEM
    if [[ "$1" =~ ^[0-9]+[GM]$ ]]; then
        MEM="$1"; shift
    else
        MEM="32G"
    fi

    # 3) CPUS
    if [[ "$1" =~ ^[0-9]+$ ]]; then
        CPUS="$1"; shift
    else
        CPUS="16"
    fi

    # 4) GPUS
    if [[ "$1" =~ ^[0-9]+$ ]]; then
        GPUS="$1"; shift
    else
        GPUS="0"
    fi

    # 5) SCRIPT
    if [[ -z "$1" ]]; then
        echo "Error: No script specified."
        usage
        return 1
    fi
    SCRIPT="$1"; shift
    ARGS=("$@")

    echo "Submitting SLURM job with:"
    echo "  Time:          $TIME"
    echo "  Memory:        $MEM"
    echo "  CPUs per task: $CPUS"
    echo "  GPUs per task: $GPUS"
    echo "  Script:        $SCRIPT"
    echo "  Additional args: ${ARGS[*]}"

    # sbatch-Aufruf
    if (( GPUS == 0 )); then
        sbatch --time="$TIME" --mem="$MEM" --cpus-per-task="$CPUS" \
            ~/scripts/uv_run.slurm "$SCRIPT" "${ARGS[@]}"
    else
        sbatch --time="$TIME" --mem="$MEM" --cpus-per-task="$CPUS" \
            --gres=gpu:tesla:"$GPUS" -p gpu \
            ~/scripts/uv_run.slurm "$SCRIPT" "${ARGS[@]}"
    fi
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
