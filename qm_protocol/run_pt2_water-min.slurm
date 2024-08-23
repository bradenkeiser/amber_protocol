#!/bin/sh
#SBATCH --nodes=1               # 1 node is used
#SBATCH --cpus-per-task=1     # 4 MPI tasks
#SBATCH --ntasks=32      # Number of OpenMP threads per MPI task
#SBATCH --job-name=amber      # Jobname
#SBATCH --output=amb_param_eq.o%j  # Standard output file (%j is the job number)
#SBATCH --error=amb_param_eq.o%j   # Standard error file
#SBATCH --time=09:00:00         # Expected runtime HH:MM:SS (max 100h)
#SBATCH --partition=compute
##
module purge

module load Amber/22-foss2021b-CUDA-11.4.1 # loads amber22 with cuda


echo "the starting time is at:"
date +"%T"


#!/bin/bash

echo "Starting the minimization procedures"

base=${pwd}
mpi=32

protocol=/tarafs/data/project/proj0184-AISYN/hmg/qm_protocol

cd $base

echo "THIS USES MPI=$mpi"
echo "If it isn't running, reduce this number in this file at:"
echo "ntasks=#"
echo "mpi=#"

cp $protocol/pt2_water_min.sh ./

bash pt2_water_min.sh $base $mpi

echo "get ending time and balance"
date +"%T"
