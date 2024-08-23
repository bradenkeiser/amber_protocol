module load Amber/22-foss2021b-CUDA-11.4.1

#!/bin/bash

echo "performing analysis from the base temperature testing dir"
echo "NEED TO SPECIFY TEST_NUM MODEL TEMP"
test_num=$1
model=$2
temp=$3
base=$(pwd)
test=t${test_num}-heat/eq/prod
cp ../qm_protocol/cpptraj_inputs/data_analysis.in $test/./
cp ../qm_protocol/cpptraj_inputs/protlig_info.in $test/./
cd $test
cp ../../../min_final/protlig-solv.prmtop ./

mkdir results

cp data_analysis.in protlig_info.in results/./

cd results/
cat data_analysis.in
cpptraj -p ../protlig-solv.prmtop -y ../prod.nc -i data_analysis.in

cpptraj -i protlig_info.in

mv ligrmsd.xvg ${model}_${test_num}_20ns_rmsd.xvg
#cpptraj -p tpr-protein.pdb -y trj-protein.xtc -x trj-protein.dcd

source ~/.bashrc
conda activate renv
Rscript ~/scripts/deck/hmg/hmg_singleanalyses.R $(pwd) tpr-protein.pdb trj-protein.dcd $model $temp $test_num

echo "scripts run, files made, cleaning up"
#rm protein*.xvg
tar cfvz ${model}_${temp}_${test_num}.tar.gz *.xvg tpr-protein.pdb trj-small.xtc 

echo "data is present at: "
echo $(pwd)/${model}_${temp}_${test_num}.tar.gz


