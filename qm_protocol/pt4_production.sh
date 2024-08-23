#!/bin/bash

echo "RUNNING STANDARD COMPLEX SIM FOR 20NS, 4 TRAJECTORIES"
model=$1
test_num=$2
BASEDIR=/tarafs/data/project/proj0184-AISYN/hmg
PROTOCOL=${BASEDIR}/qm_protocol
PRODDIR=${BASEDIR}/$model/t${test_num}-heat/eq/prod
MINDIR=${BASEDIR}/${model}/min_final


mkdir ${PRODDIR}
cp ${PROTOCOL}/amber_inputs/prod.in ${PRODDIR}


cp ${PROTOCOL}/cpptraj_inputs/200_concat.in ${PRODDIR}
cd $PRODDIR
sed -i 's/TEMP/300/g' prod.in

echo "running for 20ns, four trajectories"
sed -i "s/100000000/12500000/g" prod.in
pmemd.cuda -O -i $PRODDIR/prod.in \
    -o $PRODDIR/prod1.out \
    -p ${MINDIR}/protlig-solv.prmtop  \
    -c $PRODDIR/../eq.rst \
    -r $PRODDIR/prod1.rst \
    -x $PRODDIR/prod1.nc \
    -ref ${MINDIR}/protlig-solv.inpcrd
echo "running second trajectory"
pmemd.cuda -O -i $PRODDIR/prod.in \
    -o $PRODDIR/prod2.out \
    -p ${MINDIR}/protlig-solv.prmtop  \
    -c $PRODDIR/prod1.rst \
    -r $PRODDIR/prod2.rst \
    -x $PRODDIR/prod2.nc \
    -ref ${MINDIR}/protlig-solv.inpcrd
echo "running third trajectory"
pmemd.cuda -O -i $PRODDIR/prod.in \
    -o $PRODDIR/prod3.out \
    -p ${MINDIR}/protlig-solv.prmtop  \
    -c $PRODDIR/prod2.rst \
    -r $PRODDIR/prod3.rst \
    -x $PRODDIR/prod3.nc \
    -ref ${MINDIR}/protlig-solv.inpcrd
echo "running 4th and final trajectory"
pmemd.cuda -O -i $PRODDIR/prod.in \
    -o $PRODDIR/prod4.out \
    -p ${MINDIR}/protlig-solv.prmtop  \
    -c $PRODDIR/prod3.rst \
    -r $PRODDIR/prod4.rst \
    -x $PRODDIR/prod4.nc \
    -ref ${MINDIR}/protlig-solv.inpcrd
cp ${PROTOCOL}/cpptraj_inputs/200_concat.in ./
cp ${PROTOCOL}/get_dist.in
cpptraj -i 200_concat.in
