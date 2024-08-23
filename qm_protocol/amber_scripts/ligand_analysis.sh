#!/bin/bash

module purge
module load Amber

base=$(pwd)
protocol=${base}/../qm_protocol

test_num=$1
variant=$2

data_dir=${base}/t${test_num}-heat/eq/prod

echo "the starting directory is: ${base}"
echo "the data dir is in: $data_dir"
echo "working on test $test_num for the $variant variant"

cd $data_dir

if [[ -d results ]]; then
    echo "results directory present"
    cd results
else
    echo "results direcotry not present"
    echo "plesae run get_results.sh [test_num] [variant_name]"
    exit 1
fi

if [[ -d liginfo ]]; then
        rm -r liginfo
fi

mkdir liginfo

cd liginfo

cp $protocol/cpptraj_inputs/protlig_info.in ./

cpptraj -p ../tpr-protein.pdb -y trj-protein.dcd -i protlig_info.in

tar cfvz ${variant}-${test_num}_liginfo.tar.gz *pdb *xvg *xtc *csv

cwd=$(pwd)
echo "copy this for scp to transfer to your local machine:"
echo "${cwd}/${variant}-${test_num}_liginfo.tar.gz"
