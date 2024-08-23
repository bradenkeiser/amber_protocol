#!/bin/bash
dir=$1
cd $dir
echo "running em with..."

cat protlig_min.in

amber_prog="mpirun -np 4 pmemd.MPI"
$amber_prog -O -i protlig_min.in -p protlig-nosolv.prmtop -c protlig-nosolv.inpcrd -o protlig-min.out -r protlig-min1.rst7 -inf mdinfo -ref protlig-nosolv.inpcrd


