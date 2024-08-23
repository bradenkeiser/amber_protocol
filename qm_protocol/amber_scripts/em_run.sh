#!/bin/bash
dir=$1
cd $dir
echo "running em with..."
amber_prog="mpirun -np 4 sander.MPI"
cat min.in
$amber_prog -O -i min.in -p prot-solv.prmtop -c prot-solv.inpcrd -o min.out -r min1.rst7 -inf mdinfo -ref prot-solv.inpcrd


