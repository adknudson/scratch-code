#!/bin/bash
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=16
#SBATCH --mem-per-cpu=512M
#SBATCH --job-name=run_sims

myscript=$HOME/Repos/scratch-code/r_stuff/test_slurm/test_argparse.R

for fixed in 0 1
do
    for reps in 3 5 10 20 100
    do

       srun --ntasks 4 --exclusive --time=2 Rscript ${myscript} --reps ${reps} --fixed ${fixed} &

    done
done
wait

