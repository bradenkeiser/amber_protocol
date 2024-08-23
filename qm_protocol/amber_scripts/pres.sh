#!/bin/bash
dir=$1
temp=$2
cd $dir
if [[ -z $temp ]]; then
    echo 'temp not specified, assumming 300'
    sed -i 's/TEMP/300/g' npt.in
else
    echo "temp will be set to: $temp"
    sed -i "s/TEMP/$temp/g" npt.in
fi

if [[ -z $3 ]]; then
	echo "using residue 203 for ligand, cutinase assumed"
else
	echo "changing restrained residue to: $3"
	sed -i "s/:203/:$3/g" npt.in
fi
amber_prog="mpirun -np 4 pmemd.MPI"
echo "running the following heatuilibration:"
cat npt.in
    $amber_prog -O -i npt.in -p ../../prot-solv.prmtop -c ../heat.rst  -o pres.out -r pres.rst -inf mdinfo -ref ../../prot-solv.inpcrd





