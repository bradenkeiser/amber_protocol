#!/bin/bash
if [[ $# < 2 ]]; then
    echo "this script requires two inputs: the protein file name WITHOUT '.pdb' extension"
    echo "and y/n for deleting input folder (restarting)"
    exit 1
else
    base=$(pwd)
    echo "this is the mutant parent folder: $base"
    echo "this scripts makes amber inputs for ligand, protein,"
    echo "and an additional total complex with water and ions"
    echo "it uses openbabel to properly add all hydrogens to ligand before"
    echo "creating correct ligand topology files; it also renames the output."
    if [[ $2 == y ]]; then
        echo "the process will restart with deleting the alpha input folder"
    else
        echo "the process will begin or continue based on a previous run"
        echo "input folder won't be deleted"
    fi
fi

source /home/deck/bashrc

#test=/home/deck/amber/tleap
#amber=/home/deck/amber/run
base=$(pwd)
run=$1
protocol=/tarafs/data/project/proj0184-AISYN/hmg/qm_protocol

cd $base
if [ $2 == 'y' ]; then
    echo "input directory present"
    rm -r input
    mkdir input
    cp ${run}.pdb input/./
else
    if [[ -d input ]]; then
        echo "input directory present, doing nothing"
        cp ${run}.pdb input/./

    else
        echo "input directory not found, making..."
        mkdir input
        cp ${run}.pdb input/./
    fi
fi
cd input
cp $protocol/tleap_inputs/tleap-protlig.in $protocol/tleap_inputs/tleap-prot.in \
    $protocol/tleap_inputs/tleap-qmbox.in $protocol/tleap_inputs/tleap-chk.in ./

sed -i "s/tpr/complex_renum/g" tleap-protlig.in

echo "work on the ligand"
awk '$1=="ATOM" || $1=="HETATM" || $1=="TER" || $1=="END" || $1="CONECT"' ${run}.pdb > ${run}_protligclean.pdb
awk '$1=="ATOM" || $1=="TER" || $1=="END"' ${run}_protligclean.pdb > ${run}_clean.pdb

echo "This script uses the pre-processed ligand files"
echo 'convert cleaned protein file to amber'

pdb4amber -i ${run}_clean.pdb -o ${run}_clean_amber.pdb
#run=dimer_lig_hip741_protonated

echo "bring over the ligand files"

cp $protocol/ligfiles/HMG.frcmod $protocol/ligfiles/nadph.frcmod $protocol/ligfiles/nap.lib \
    $protocol/ligfiles/nap.lib $protocol/ligfiles/hmg.lib $protocol/ligfiles/mol2pdb_nap.pdb \
    $protocol/ligfiles/mol2pdb_hmg.pdb ./
if  [ -f ${run}_clean_amber.pdb ] && [ -f HMG.frcmod ] && [ -f nadph.frcmod ]; then
    echo " ligand frcmod file found"
    #awk 'NR==FNR {if ($1!="END") print $0} NR>FNR {if ($4=="LIG") print $0}' ${run}_clean_amber.pdb mol2pdb.pdb > complex.pdb

    data+=$(grep -n TER ${run}_clean_amber.pdb | awk -F: '{print $1}')
    dummy=0
    dummy2=0
    for x in ${data[@]}; do
        echo "this is the number of TER: $x"
        if [[ $dummy == 0 ]]; then
            echo "working on dummy 1 first TER at $x"
            sed "${x}r mol2pdb_nap.pdb" ${run}_clean_amber.pdb > complex.pdb
            dummy=1
        elif [[ $dummy == 1 ]]; then
            echo "moving to next"
            data2+=$(grep -n TER complex.pdb | awk -F: '{print $1}')
            for y in ${data2[@]}; do
                if [[ $dummy2 == 1 ]]; then
                    echo "proceeding"
                    echo "working on dummy2 $dummy2 and line number $y"
                    sed -i "${y}r mol2pdb_hmg.pdb" complex.pdb
                fi
                if [[ $dummy2 == 0 ]]; then
                    echo "first dummy2 passed"
                    dummy2=1
                fi
            done
        fi
    done
    #sed -i '/HE2 GLU/D' complex.pdb; sed -i '/H   ALA/D' complex.pdb
    pdb4amber -i complex.pdb -o complex_amber.pdb; awk '$1!="CONECT"' complex_amber.pdb > complex_nocnct.pdb
    cp complex_nocnct.pdb complex_fin.pdb
    awk '!/HETATM/' complex_fin.pdb > protein_fin.pdb
    echo "using Tleap"
    sed -i 's/PROTEIN/protein_fin/g' tleap-chk.in
    tleap -s -f tleap-chk.in > tleap-chk.out
    chg_pre=$(grep unperturbed tleap-chk.out | awk '{print $7}')
    echo "this is the total charge on the protein: $chg_pre"
    chg=${chg_pre:1:1}
    echo "this is the charge: $chg"
    echo "Don't be alarmed by no charge found, here is just protocol"
    echo "IONS WILL BE CORRECTLY INSERTED DURING WATER MINIMIZATION IN PT 2"
    if [[ $chg == '-' ]]; then
        chg_qty=${chg_pre:2:2}
        echo "charge is negative, need to add $chg_qty sodiums"
        sed -i 's/IONS/Na+/g' tleap-qmbox.in
        sed -i "s/QTY/$chg_qty/g" tleap-qmbox.in
        cat tleap-qmbox.in
    elif [[ ($chg != '-') && ($chg -gt 0) ]]; then
        chg_qty=${chg_pre:1:1}
        echo "charge is positive, need to add $chg_qty chlorine ions"
        sed -i 's/IONS/Cl-/g' tleap-qmbox.in
        sed -i "s/QTY/$chg_qty/g" tleap-qmbox.in
        cat tleap-qmbox.in
    elif [[ -z $chg ]]; then
        echo "charge not identified or neutral, adding 0"
        sed -i 's/IONS/Na+/g' tleap-qmbox.in
        sed -i "s/QTY/0/g" tleap-qmbox.in
        cat tleap-qmbox.in
    fi
    tleap -s -f tleap-prot.in > tleap-prot.out
    tleap -s -f tleap-qmbox.in > tleap-qmbox.out
else
    echo "no de-hipped protein file found, aborting..."
fi

