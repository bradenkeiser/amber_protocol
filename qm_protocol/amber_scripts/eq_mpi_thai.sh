#!/bin/bash
dir=$1
temp=$2
cd $dir
if [[ -z $temp ]]; then
    echo 'temp not specified, assumming 300'
    sed -i 's/TEMP/300/g' eq.in
else
    echo "temp will be set to: $temp"
    sed -i "s/TEMP/$temp/g" eq.in
fi

echo "doing mpi run"
amber_prog="mpirun -np 16 pmemd.MPI"
$amber_prog -O -i eq.in -p ../../prot-solv.prmtop -c ../heat.rst  -o eq.out -r eq.rst -inf mdinfo -ref ../../prot-solv.inpcrd
