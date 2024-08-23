#!/bin/bash
dir=$1
temp=$2
mindir=$3
cd $dir
if [[ -z $temp ]]; then
    echo 'temp not specified, assumming 300'
    sed -i 's/TEMP/300/g' qm_eq.in
else
    echo "temp will be set to: $temp"
    sed -i "s/TEMP/$temp/g" qm_eq.in
fi

echo "doing mpi run"
amber_prog="mpirun -np 16 pmemd.MPI"
$amber_prog -O -i qm_eq.in -p ${mindir}/protlig-solv.prmtop -c ../heat.rst  -o eq.out -r eq.rst -inf mdinfo -ref ${mindir}/protlig-solv.inpcrd
