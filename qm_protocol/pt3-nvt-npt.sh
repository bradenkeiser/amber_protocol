#!/bin/bash

if [[ $# < 3 ]]; then
    echo "Must supply:"
    echo "Test number, temperature, and mpi"
    exit 1
fi


test_num=$1
if [[ -z $2 ]]; then
    echo "temp command left out, assumming 300K"
    temp=300
else
    temp=$2
fi


PROTOCOL=/tarafs/data/project/proj0184-AISYN/hmg/qm_protocol

BASEDIR=$(pwd)

if [[ -d min_final ]]; then 
	echo "min_final directory present"
else 
	mkdir ${BASEDIR}/min_final
        cp ${BASEDIR}/input/protlig_min/water_minimization/protlig-solv*  min_final/./
fi

tpr=${BASEDIR}/min_final/protlig-solv.prmtop
trj=${BASEDIR}/min_final/protlig-solv.inpcrd
EMDIR=${BASEDIR}/input/protlig_min/water_minimization
cp $EMDIR/protlig-min4.rst7 ${BASEDIR}/min_final/./

mkdir t${test_num}-heat

echo 'performing NVT'

NVTDIR=${BASEDIR}/t${test_num}-heat
mkdir ${NVTDIR}
cp ${PROTOCOL}/amber_inputs/qm_nvt.in ${NVTDIR}/./
if [[ -z $3 ]]; then
    echo "using default values for ensembles and mpi"
    bash ${PROTOCOL}/amber_scripts/heat.sh ${NVTDIR} $temp
elif [[ $3 == 'test' ]]; then
    echo "running test protocols"
    sed -i 's/30000/500/g' ${NVTDIR}/qm_nvt.in
    if [[ -z $4 ]]; then
        echo "using default values for MPI = 16"
        bash ${PROTOCOL}/amber_scripts/heat.sh ${NVTDIR} $temp
    else
        echo "using mpi with the value: $4"
        cp ${PROTOCOL}/amber_scripts/qm_heat_mpi.sh ${NVTDIR}/./
        sed -i "s/np 4/np $4/g" ${NVTDIR}/qm_heat_mpi.sh
        bash ${NVTDIR}/qm_heat_mpi.sh ${NVTDIR} $temp ${BASEDIR}/min_final
    fi
else
    if [[ -z $4 ]]; then
        echo "using default values for MPI = 16"
        bash ${PROTOCOL}/amber_scripts/heat.sh ${NVTDIR} $temp
    else
        echo "using mpi with the value: $4"
        cp ${PROTOCOL}/amber_scripts/qm_heat_mpi.sh ${NVTDIR}/./
        sed -i "s/np 4/np $4/g" ${NVTDIR}/qm_heat_mpi.sh
        bash ${NVTDIR}/qm_heat_mpi.sh ${NVTDIR} $temp ${BASEDIR}/min_final
    fi

fi


echo "ensembles finished, performing EQ for 1ns..."

EQDIR=${NVTDIR}/eq
mkdir ${EQDIR}
cp ${PROTOCOL}/amber_inputs/qm_eq.in ${EQDIR}/./
if [[ -z $3 ]]; then
    echo "using default values for ensembles and mpi = 16"
    bash ${PROTOCOL}/amber_scripts/eq_thai.sh ${EQDIR} $temp
elif [[ $3 == 'test' ]]; then
    echo "running test protocols"
    sed -i 's/nstlim=500000/nstlim=5000/g' ${EQDIR}/eq.in
    sed -i 's/ntpr=5000/ntpr=50/g' ${EQDIR}/qm_eq.in
    sed -i 's/ntwx=5000/ntwx=50/g' ${EQDIR}/qm_eq.in
    if [[ -z $4 ]]; then
        echo "using default values for MPI = 16"
        bash ${PROTOCOL}/amber_scripts/eq_thai.sh ${EQDIR} $temp
    else
        echo "using mpi with the value: $4"
        cp ${PROTOCOL}/amber_scripts/qm_eq_mpi_thai.sh ${EQDIR}/./
        sed -i "s/np 4/np $4/g" ${EQDIR}/qm_eq_mpi_thai.sh
        bash ${EQDIR}/qm_eq_mpi_thai.sh ${EQDIR} $temp ${BASEDIR}/min_final
    fi
else
    if [[ -z $4 ]]; then
        echo "using default values for MPI = 16"
        bash ${PROTOCOL}/amber_scripts/eq_thai.sh ${EQDIR} $temp
    else
        echo "using mpi with the value: $4"
        cp ${PROTOCOL}/amber_scripts/qm_eq_mpi_thai.sh ${EQDIR}/./
        sed -i "s/np 16/np $4/g" ${EQDIR}/qm_eq_mpi_thai.sh
        bash ${EQDIR}/qm_eq_mpi_thai.sh ${EQDIR} $temp ${BASEDIR}/min_final
    fi
fi
