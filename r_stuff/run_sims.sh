#!/usr/bin/bash
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=4
#SBATCH --cpus-per-task=4
#SBATCH --mem-per-cpu=512M

myscript=$HOME/Repos/scratch-code/r_stuff/test_argparse.R

for fixed in 0 1
do
    for reps in 3 5 15 30
    do

       srun --exclusive --time=240 Rscript ${myscript} --reps $reps --fixed $fixed &

    done
done
wait
