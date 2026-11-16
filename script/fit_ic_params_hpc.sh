#!/bin/bash
# Parameter search for the 7 initial conditions of py/results/ic_param_search/cases.py,
# one array task per case, each using all CPUs of its allocation.
#
# Submit from the repository root:   sbatch script/fit_ic_params_hpc.sh
# Progress:                          tail -f slurm-ic-params-<job>_<task>.out
#                                    python py/results/ic_param_search/fit_params.py --list
# Afterwards, merge the results:     python py/results/ic_param_search/collect_params.py
#
# A timed out task resumes where it stopped when submitted again (same --trials and --cells).
# Rough cost: one solve ~45 s with 20 cells per particle, so 500 trials on 32 CPUs is ~15 min
# per case. Adjust --cpus-per-task to the nodes of the partition.

#SBATCH -p main
#SBATCH --job-name=ic-params
#SBATCH --array=0-6
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=32
#SBATCH --time=04:00:00
#SBATCH --output=slurm-ic-params-%A_%a.out

source ~/miniconda3/etc/profile.d/conda.sh
conda activate yag_model

# The solver is single threaded, keep numpy from starting its own thread pools in every worker
export OMP_NUM_THREADS=1 OPENBLAS_NUM_THREADS=1 MKL_NUM_THREADS=1

cd "$SLURM_SUBMIT_DIR"
python -u py/results/ic_param_search/fit_params.py --case-index "$SLURM_ARRAY_TASK_ID" --trials 500
