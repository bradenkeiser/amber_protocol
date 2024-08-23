#!/bin/sh
#SBATCH --nodes=1               # 1 node is used
#SBATCH --cpus-per-task=1     # allocate a cpu with tasks
#SBATCH --ntasks=1      # Number of OpenMP threads per MPI task
#SBATCH --job-name=amber      # Jobname
#SBATCH --output=amb_prod.o%j  # Standard output file (%j is the job number)
#SBATCH --error=amb_prod.o%j   # Standard error file
#SBATCH --time=80:00:00         # Expected runtime HH:MM:SS (max 100h)
#SBATCH --partition=gpu
##
module purge

module load Amber/22-foss2021b-CUDA-11.4.1 # loads amber22 with cuda


#!/bin/bash 

model=$1
test_num=$2
RUN=/tarafs/data/project/proj0184-AISYN/hmg/qm_protocol
DATADIR=$(pwd)
cd $DATADIR # enter the hardcoded temp test folder
export PATH=$DATADIR:$PATH
bash ${RUN}/pt4_production.sh $model $test_num



