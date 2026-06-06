#!/bin/bash
#SBATCH -p main
#SBATCH -n 32

source ~/miniconda3/etc/profile.d/conda.sh
conda activate yag_model

for i in $(seq 1 32)
do
    python py/find_params_hpc.py &
done

wait