#!/bin/bash

source /home/deck/bashrc

test=/home/deck/amber/tleap
amber=/home/deck/amber/run
protocol=/home/deck/xylanase/finding_ES_model/qm_protocol
base=$1

cd $base/input

if [[ -f protlig-nosolv.prmtop ]]; then
    echo 'non-solvated complex present'
else
    echo "check your initial parameterization"
    echo "non-solvated complex is not present, aborting..."
    exit 1
fi

mkdir protlig_min
cd protlig_min

cp $protocol/amber_inputs/protlig_min.in ./
amber_prog="mpirun -np 4 pmemd.MPI"

$amber_prog -O -i protlig_min.in -p ../protlig-nosolv.prmtop -c ../protlig-nosolv.inpcrd -o protlig-min.out -r protlig-min1.rst7 -inf mdinfo -ref ../protlig-nosolv.inpcrd

cpptraj -p ../protlig-nosolv.prmtop -y protlig-min1.rst7 -x protlig_min_fin.pdb

mkdir water_minimization

cp $protocol/tleap_inputs/tleap-chk.in $protocol/tleap_inputs/tleap-protlig.in \
    $protocol/tleap_inputs/tleap-qmbox.in protlig_min_fin.pdb water_minimization/./

cd water_minimization


tleap -s -f tleap-chk.in > tleap-chk.out
chg_pre=$(grep unperturbed tleap-chk.out | awk '{print $7}')
echo "this is the total charge on the protein: $chg_pre"
chg=${chg_pre:1:1}
echo "this is the charge: $chg"
if [[ $chg == '-' ]]; then
    chg_qty=${chg_pre:2:2}
    echo "charge is negative, need to add $chg_qty sodiums"
    sed -i 's/IONS/Na+/g' tleap-protlig.in
    sed -i "s/QTY/$chg_qty/g" tleap-protlig.in
    cat tleap-protlig.in
elif [[ ($chg != '-') && ($chg -gt 0) ]]; then
    chg_qty=${chg_pre:1:1}
    echo "charge is positive, need to add $chg_qty chlorine ions"
    sed -i 's/IONS/Cl-/g' tleap-protlig.in
    sed -i "s/QTY/$chg_qty/g" tleap-protlig.in
    cat tleap-protlig.in
elif [[ -z $chg ]]; then
    echo "charge not identified or neutral, adding 0"
    sed -i 's/IONS/Na+/g' tleap-protlig.in
    sed -i "s/QTY/0/g" tleap-protlig.in
    cat tleap-protlig.in
fi
tleap -s -f tleap-protlig.in > tleap-protlig.out

cp $protocol/amber_inputs/water_min* ./

protsolv=$(pwd)
echo "the directory with the solvated complexes is here: $protsolv"

amber_prog="mpirun -np 4 pmemd.MPI"
echo "running first water minimization: restraints = 500"
$amber_prog -O -i water_min1.in -p protlig-solv.prmtop -c protlig-solv.inpcrd -o protlig-water_min1.out -r protlig-min2.rst7 -inf mdinfo1 -ref protlig-solv.inpcrd
echo "running second water minimization: restraints = 10 "
$amber_prog -O -i water_min2.in -p protlig-solv.prmtop -c protlig-min2.rst7 -o protlig-water_min2.out -r protlig-min3.rst7 -inf mdinfo2 -ref protlig-solv.inpcrd
echo "running third and final minimization: no restraints"
$amber_prog -O -i water_min3.in -p protlig-solv.prmtop -c protlig-min3.rst7 -o protlig-water_min3.out -r protlig-min4.rst7 -inf mdinfo3 -ref protlig-solv.inpcrd

cpptraj -p protlig-solv.prmtop -y protlig-min4.rst7 -x protlig-solv-minimized-final.pdb
