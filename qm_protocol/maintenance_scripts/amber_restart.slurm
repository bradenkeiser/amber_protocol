#!/bin/sh
#SBATCH --nodes=1               # 1 node is used
#SBATCH --cpus-per-task=1     # allocate a cpu with tasks
#SBATCH --ntasks=32      # Number of OpenMP threads per MPI task
#SBATCH --job-name=amber_restart      # Jobname
#SBATCH --output=amb_prod_restart.o%j  # Standard output file (%j is the job number)
#SBATCH --error=amb_prod_restart.o%j   # Standard error file
#SBATCH --time=04:00:00         # Expected runtime HH:MM:SS (max 100h)
#SBATCH --partition=compute
##
module purge

module load Amber/22-foss2021b-CUDA-11.4.1 # loads amber22 with cuda


#!/bin/bash

test_num=$1 # the testing directory to be used
temp='300'
#cp protocol/cpptraj_inputs/concat.in ${DATADIR}/test${test_num}/input/em/heat/eq/prod

DATADIR=$(pwd)
cd $DATADIR # enter the hardcoded temp test folder

export PATH=$DATADIR:$PATH
EQDIR=${DATADIR}/t${test_num}-heat/eq
cd ${EQDIR}

bash ${EQDIR}/qm_eq_mpi_thai.sh ${EQDIR} $temp ${DATADIR}/min_final
