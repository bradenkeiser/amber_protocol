#!bin/bash
echo "this takes a relaxed PDB file and properly protonates it for Amber"
echo "The HID conformation of histidines is produced for all His"
model=$1 # name of PDB file WITHOUT '.pdb'

awk '$1=="ATOM" || $1=="TER" || $1=="END"' ${model}.pdb > ${model}_clean.pdb

pdb2pqr30 --ff=AMBER --ffout=AMBER --keep-chain --titration-state-method propka --with-ph 6.5 --pdb-output=pre.pdb ${model}_clean.pdb ${model}_clean.pqr
#echo "DELETE ALL HIP HE2 ATOMS and RENAME that to HID"
#sed '/HE2 HIP/D' pre.pdb > ${model}_prefix.pdb # manually converts HIP to HID if present
#sed 's/HIP/HID/g' ${model}_prefix.pdb > ${model}_protonated.pdb
cp pre.pdb ${model}_protonated.pdb
