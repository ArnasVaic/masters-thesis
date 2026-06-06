#!/bin/bash
#SBATCH -p main
#SBATCH -n 32

source ~/miniconda3/etc/profile.d/conda.sh
conda activate yag

srun -n 32 python py/find_params_hpc.py