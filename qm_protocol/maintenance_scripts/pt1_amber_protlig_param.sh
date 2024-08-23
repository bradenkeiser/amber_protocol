#!/bin/bash
if [[ $# < 2 ]]; then
    echo "this script requires two inputs: mutant (parent folder name)"
    echo "and y/n for deleting input folder (restarting)"
    echo "and h/p for h++ webserver or pdb2pqr"
    exit 1
else
    echo "this is the mutant parent folder: $1"
    echo "this scripts makes amber inputs for ligand, protein with metal (Fe2+),"
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

test=/home/deck/amber/tleap
amber=/home/deck/amber/run
base=$3
run=$1
protocol=/home/deck/xylanase/finding_ES_model/qm_protocol

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
cp $amber/em_run.sh $amber/heat.sh ./

cd input
cp $protocol/tleap_inputs/tleap-protlig.in $protocol/tleap_inputs/tleap-prot.in \
        $protocol/tleap_inputs/tleap-lig.in $protocol/tleap_inputs/tleap-qmbox.in \
        $protocol/tleap_inputs/tleap-chk.in ./
sed -i "s/tpr/complex_renum/g" tleap-protlig.in

echo "work on the ligand"
awk '$1=="ATOM" || $1=="HETATM" || $1=="TER" || $1=="END" || $1="CONECT"' ${run}.pdb > ${run}_protligclean.pdb
awk '$1=="ATOM" || $1=="TER" || $1=="END"' ${run}_protligclean.pdb > ${run}_clean.pdb

if [ -f resp/lig_resp.mol2 ]; then
    echo "ligand already processed"
    echo "resp directory and RESPed mol2 present, moving on..."
    cp resp/lig_resp.mol2 ./
    parmchk2 -f mol2 -i lig_resp.mol2 -o LIG.frcmod -s 2
    echo "generate the topology pdb from the mol2 using cpptraj"
    cpptraj -p lig_resp.mol2 -y lig_resp.mol2 -x mol2pdb_pre.pdb; awk '$1=="ATOM" || $1=="TER" || $1=="END"' mol2pdb_pre.pdb > mol2pdb.pdb
    tleap -s -f tleap-lig.in > tleap_lig.out
else
    sed -i 's/U NL/ UNL/g' ${run}_protligclean.pdb
    sed -i 's/ UNL/ LIG/g' ${run}_protligclean.pdb
    grep LIG ${run}_protligclean.pdb > lig.pdb
    reduce lig.pdb > lig_pre.pdb
    obabel -h -i pdb lig_pre.pdb -o pdb -O lig_notamber.pdb # adds hydrogens to ligand files
    pdb4amber -i lig_notamber.pdb -o lig_hy.pdb #need to convert the obabel to amber format before running antechamber
    antechamber -fi pdb -fo mol2 -i lig_hy.pdb -o lig.mol2 -rn LIG -c bcc -pf y -nc 0 -s 2 -at gaff2
    echo "mol2 generated, starting RESP procedure"
    if [[ -d resp && -f resp/lig_resp.mol2 ]]; then
        echo "resp directory and RESPed mol2 present, moving on..."
        cp resp/lig_resp.mol2 ./
    else
        mkdir resp
        cp lig.mol2 lig_notamber.pdb resp/./
        cd resp
        cp $amber/g09_respguide.sh ./
        bash g09_respguide.sh
        cp lig_resp.mol2 .././ && cd ../
    fi
    parmchk2 -f mol2 -i lig_resp.mol2 -o LIG.frcmod -s 2
    echo "generate the topology pdb from the mol2 using cpptraj"
    cpptraj -p lig_resp.mol2 -y lig_resp.mol2 -x mol2pdb_pre.pdb; awk '$1=="ATOM" || $1=="TER" || $1=="END"' mol2pdb_pre.pdb > mol2pdb.pdb

    tleap -s -f tleap-lig.in > tleap_lig.out
fi

echo "make sure lig.mol2 = <ligand name in PDB>.mol2 OR FRCMOD"
echo "work with the pdb file"


echo 'convert cleaned protein file to amber'

pdb4amber -i ${run}_clean.pdb -o ${run}_clean_amber.pdb

if  [ -f ${run}_clean_amber.pdb ] && [ -f LIG.frcmod ]; then
    echo "no HIP residues present, concatenating..."
    echo " ligand frcmod file found"
    awk 'NR==FNR {if ($1!="END") print $0} NR>FNR {if ($4=="LIG") print $0}' ${run}_clean_amber.pdb mol2pdb.pdb > complex.pdb
    #sed -i '/HE2 GLU/D' complex.pdb; sed -i '/H   ALA/D' complex.pdb
    pdb4amber -i complex.pdb -o complex_amber.pdb; awk '$1!="CONECT"' complex_amber.pdb > complex_nocnct.pdb
    cp complex_nocnct.pdb complex_fin.pdb
    awk '$1!="HETATM"' complex_fin.pdb > protein_fin.pdb
    echo "using Tleap"
    sed -i 's/PROTEIN/protein_fin/g' tleap-chk.in
    tleap -s -f tleap-chk.in > tleap-chk.out
    chg_pre=$(grep unperturbed tleap-chk.out | awk '{print $7}')
    echo "this is the total charge on the protein: $chg_pre"
    chg=${chg_pre:1:1}
    echo "this is the charge: $chg"
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

