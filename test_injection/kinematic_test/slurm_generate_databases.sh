#!/usr/bin/bash

## job name and output file
#SBATCH --job-name specfem_generate_databases
#SBATCH --output %j.o

###########################################################
# USER PARAMETERS

## 40 CPUs ( 10*4 ), walltime 5 hour
#SBATCH --nodes=3
#SBATCH --ntasks=120
#SBATCH --time=00:15:00

###########################################################

cd $SLURM_SUBMIT_DIR
module load intel openmpi python/3.6.8

NPROC=`grep ^NPROC DATA/Par_file | grep -v -E '^[[:space:]]*#' | cut -d = -f 2`

BASEMPIDIR=`grep ^LOCAL_PATH DATA/Par_file | cut -d = -f 2 `

mpirun -np $NPROC ./bin/xgenerate_databases
