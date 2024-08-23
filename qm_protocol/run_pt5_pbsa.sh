#!/bin/sh
#SBATCH --nodes=1               # 1 node is used
#SBATCH --cpus-per-task=1     # 4 MPI tasks
#SBATCH --ntasks=32      # Number of OpenMP threads per MPI task
#SBATCH --job-name=amber      # Jobname
#SBATCH --output=amb_eq.o%j  # Standard output file (%j is the job number)
#SBATCH --error=amb_eq.o%j   # Standard error file
#SBATCH --time=24:00:00         # Expected runtime HH:MM:SS (max 100h)
#SBATCH --partition=compute
##
module purge

module load Amber/22-foss2021b-CUDA-11.4.1 # loads amber22 with cuda


echo "the starting time is at:"
date +"%T"


#!/bin/bash
test_num=$1
variant=$2
lig=$3
mpi=$4

echo "running $model on test $test with $3 mpi"

PROTOCOL=/tarafs/data/project/proj0184-AISYN/hmg/qm_protocol
cp ${PROTOCOL}/amber_scripts/amber_pbsa.sh ./

bash amber_pbsa.sh $test_num $variant $lig $mpi

echo "get ending time and balance"
date +"%T"
