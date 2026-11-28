#!/bin/bash
# Parameter search for the 7 initial conditions of py/results/ic_param_search/cases.py,
# one array task per case, each using all CPUs of its allocation.
#
# Once, on the login node, from the repository root:
#   source ~/miniforge3/etc/profile.d/conda.sh
#   conda env create -f environment.yml
#   conda activate yag_model && pip install -e . --no-build-isolation
#
# Submit from the repository root:   sbatch script/fit_ic_params_hpc.sh
# With another molar ratio:          sbatch script/fit_ic_params_hpc.sh experiment
#                                    sbatch script/fit_ic_params_hpc.sh 5:2.9
#   stoichiometric (default, 5:3), experiment (the ratio implied by the experiment's mass
#   percentages, about 5:2.79) or Al2O3:Y2O3. Each ratio other than 5:3 writes to its own
#   py/results/ic_param_search/data-<ratio>/, so runs of different ratios can go at the same time.
#   For progress and merging, prefix the commands below with IC_PARAM_SEARCH_RATIO=<same ratio>.
# Progress:                          tail -f slurm-ic-params-<job>_<task>.out
#                                    python py/results/ic_param_search/fit_params.py --list
# Afterwards, merge the results:     python py/results/ic_param_search/collect_params.py
#
# A timed out task resumes where it stopped when submitted again (same --trials and --cells).
# Rough cost: one solve ~45 s with 20 cells per particle, so 1500 trials on 32 CPUs is ~40 min
# per case. Adjust --cpus-per-task to the nodes of the partition.

#SBATCH -p main
#SBATCH --job-name=ic-params
#SBATCH --array=0-6
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=32
#SBATCH --time=04:00:00
#SBATCH --output=slurm-ic-params-%A_%a.out

echo "host $(hostname), home $HOME, submit dir $SLURM_SUBMIT_DIR"

# Miniforge or Miniconda, whichever is installed in the home directory
conda_sh=""
for conda_dir in "$HOME/miniforge3" "$HOME/miniconda3"; do
  if [ -f "$conda_dir/etc/profile.d/conda.sh" ]; then
    conda_sh="$conda_dir/etc/profile.d/conda.sh"
    break
  fi
done
if [ -z "$conda_sh" ]; then
  echo "ERROR: no conda found in $HOME/miniforge3 or $HOME/miniconda3, edit the loop above"
  exit 1
fi
source "$conda_sh"
echo "conda from $conda_sh"

if ! conda activate yag_model; then
  echo "ERROR: could not activate the yag_model environment, these exist:"
  conda env list
  exit 1
fi
echo "environment $CONDA_PREFIX"
echo "python $(command -v python), $(python --version 2>&1)"

# The solver is single threaded, keep numpy from starting its own thread pools in every worker
export OMP_NUM_THREADS=1 OPENBLAS_NUM_THREADS=1 MKL_NUM_THREADS=1

cd "$SLURM_SUBMIT_DIR"

# yag_utils is plain Python in py/. The editable install only records the absolute path it had
# at install time, which a compute node may not see the same way (e.g. a symlinked home), so take
# it straight from the checkout being run. The compiled yag_model is copied into the environment
# and does not need this.
export PYTHONPATH="$SLURM_SUBMIT_DIR/py${PYTHONPATH:+:$PYTHONPATH}"

# Fail fast if the package is not installed in this environment (see the top of this file)
if ! python -c "import yag_model, yag_utils; print('yag_model', yag_model.__file__); print('yag_utils', yag_utils.__file__)"; then
  echo "ERROR: yag_model / yag_utils cannot be imported with $(command -v python)"
  echo "installed packages named yag:"
  python -m pip list 2>/dev/null | grep -i yag || echo "  none, run pip install -e . --no-build-isolation in this environment"
  exit 1
fi

# Molar ratio from the first argument, else from the environment, else 5:3
export IC_PARAM_SEARCH_RATIO="${1:-${IC_PARAM_SEARCH_RATIO:-stoichiometric}}"
echo "molar ratio $IC_PARAM_SEARCH_RATIO"

python -u py/results/ic_param_search/fit_params.py --case-index "$SLURM_ARRAY_TASK_ID" --trials 1500
