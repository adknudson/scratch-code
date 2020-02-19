#!/bin/bash

myscript=benchmark_mvnfast.R
dims=(20 100 500 1000 2000 5000 7700 10000)
sample_size=(100000)

for d in "${dims[@]}"
do
    for N in "${sample_size[@]}"
    do
    for cores in 4
    do
        for rho in 0.5
        do

            id="d${d}-N${N}-c${cores}-r${rho}"
	    job_file=".job/${id}.slm"

	    echo "#!/bin/bash
#SBATCH --job-name=${id}.slm
#SBATCH --ouput=.out/${id}.out
#SBATCH --time=2-00:00
#SBATCH --ntasks=$cores
#SBATCH --mem=4GB

Rscript $myscript -d $d -N $N -c $cores -r $rho" > ${job_file}

            sbatch $job_file

        done
    done
    done
done

