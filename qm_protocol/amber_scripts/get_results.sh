#!/bin/bash

module purge
module load Amber

base=$(pwd)
protocol=${base}/../qm_protocol

test_num=$1
variant=$2

data_dir=${base}/t${test_num}-heat/eq/prod

echo "the starting directory is: ${base}"
echo "the data dir is in: $data_dir"
echo "working on test $test_num for the $variant variant"

cd $data_dir

if [[ -d results ]] &&  [[ -f results/trj-protein.dcd ]]; then
    echo "directory already processsed"
else
    mkdir results
    cd results
    cp $protocol/cpptraj_inputs/process_traj.in ./
    cpptraj -p $base/min_final/protlig-solv.prmtop -y ../prod.nc -i process_traj.in
fi
