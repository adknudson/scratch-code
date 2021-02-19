#!/bin/bash

subdir="_benchmark"
mkdir $subdir

Rscript --vanilla benchmark_setup.R $subdir
Rscript --vanilla benchmark_bigsimr.R $subdir bigsimr-cpu
Rscript --vanilla benchmark_bigsimr.R $subdir bigsimr-gpu
Rscript --vanilla benchmark_combine.R $subdir
