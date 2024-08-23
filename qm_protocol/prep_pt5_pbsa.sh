#!/bin/bash
if [[ $# < 4 ]]; then
    echo "this requires [test_num], [variant_name], [pbsa_start-frame], and [pbsa_end-frame]"
    exit 1
else
    echo "running $2 with test $1 starting from frame $3 and ending on frame $4"
fi


protocol=/tarafs/data/project/proj0184-AISYN/hmg/qm_protocol

base=$(pwd)
lig='HMG'
test_num=$1
variant=$2
start=$3
end=$4
tpr=protlig-solv.prmtop; trj=complex_nosolv.mdcrd
datadir=${base}/t${test_num}-heat/eq/prod
cd $datadir
mkdir prep_pbsa
cd prep_pbsa
cp $protocol/cpptraj_inputs/extract.in ./
cp ${base}/min_final/protlig-solv.prmtop ./
sed -i "s/BEG/$start/g" extract.in; sed -i "s/FIN/$end/g" extract.in
cpptraj -i extract.in
cd ${base}
mkdir pbsa_t${test_num}
cp $base/min_final/protlig-solv.prmtop $datadir/prep_pbsa/complex_nosolv.mdcrd pbsa_t${test_num}/./
cd pbsa_t${test_num}
cp $protocol/amber_inputs/mmpbsa.in $protocol/python_inputs/nearlig.py $protocol/amber_scripts/amber_pbsa.sh ./
bash amber_pbsa.sh $test_num $variant $lig 8

