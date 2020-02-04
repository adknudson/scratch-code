#!/bin/bash
for fixed in 0 1
do
  for rep in 3 5 15 30
  do
    job_id = "fit--reps${rep}--fixed${fixed}.slm"
    echo "
#!/bin/bash

Rscript test_argparse.R --reps ${rep} --fixed ${fixed}
" >
  done
done
