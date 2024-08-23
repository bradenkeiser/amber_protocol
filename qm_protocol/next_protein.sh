#!/bin/bash

if [[ $# < 2 ]]; then
    echo "this scripts makes directories for your proteins"
    echo "Required: [protein name] and [directory_name]"
    exit 1
else
    echo "making directories for $1 in $2"
fi

protein=$1
dir=$2
protocol=/tarafs/data/project/proj0184-AISYN/hmg/qm_protocol

mkdir $dir
cp $prtoein $dir/./
cp $protocol/run*slurm $dir/./.

echo "made directory: $dir"
echo "these are the contents: $(dir $dir)"
