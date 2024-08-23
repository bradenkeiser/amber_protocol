#!/bin/bash
dir=$1
temp=$2
mindir=$3
cd $dir
if [[ -z $temp ]]; then
    echo 'temp not specified, assumming 300'
    sed -i 's/TEMP/300/g' qm_nvt.in
else
    echo "temp will be set to: $temp"
    sed -i "s/TEMP/$temp/g" qm_nvt.in
fi


amber_prog="mpirun -np 4 pmemd.MPI"
echo "running the following heatuilibration:"
cat qm_nvt.in
$amber_prog -O -i qm_nvt.in -p ${mindir}/protlig-solv.prmtop -c ${mindir}/protlig-min4.rst7  -o heat.out -r heat.rst -inf mdinfo -ref ${mindir}/protlig-solv.inpcrd





