#!/bin/bash
# Compress the output found in tmp/
tar -czvf fitted_models.tar.gz tmp/

# cleanup
rm -rf tmp
rm slurm-*.out
