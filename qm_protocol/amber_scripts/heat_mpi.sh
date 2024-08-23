#!/bin/bash
dir=$1
temp=$2
cd $dir
if [[ -z $temp ]]; then
    echo 'temp not specified, assumming 300'
    sed -i 's/TEMP/300/g' nvt.in
else
    echo "temp will be set to: $temp"
    sed -i "s/TEMP/$temp/g" nvt.in
fi


amber_prog="mpirun -np 4 pmemd.MPI"
echo "running the following heatuilibration:"
cat nvt.in
$amber_prog -O -i nvt.in -p ../prot-solv.prmtop -c ../min1.rst7  -o heat.out -r heat.rst -inf mdinfo -ref ../prot-solv.inpcrd





