#!/bin/bash
#SBATCH -p main
#SBATCH -n 2

source ~/miniconda3/etc/profile.d/conda.sh
conda activate yag_model

srun -n 2 python py/find_params_hpc.py