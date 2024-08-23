module load Amber
#!/bin/bash
dirs+=$(dir -d */)

qmdir=/tarafs/data/project/proj0184-AISYN/cutinase/braden/qmmm
basedir=$(pwd)
ctraj=${qmdir}/qm_protocol/cpptraj_inputs
rm -r ctraj_data
mkdir ctraj_data
for dir in ${dirs[@]}; do
    mkdir ${basedir}/ctraj_data/data_$dir
    echo "working in ${dir%/*}"
    cd ${basedir}
    cd $dir
    rm *PROTEIN*dat *native*dat *cont*dat *hbond*dat
    cp $ctraj/distance_blank.in ./
    cp tpr*pdb tpr-200ns.pdb
    cp trj*dcd trj-200ns.dcd
    sed -i "s@PROTEIN@${dir%/*}@g" distance_blank.in
    sed -i 's/TEMP/300-200/g' distance_blank.in
    sed -i 's/150/200/g' distance_blank.in
    cpptraj -i distance_blank.in -p tpr-200ns.pdb -y trj-200ns.dcd
    cp *hbond*dat *loop* *52* *cont* *dist*dat ${basedir}/ctraj_data/data_$dir/./
done
