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


cp ${PROTOCOL}/cpptraj_inputs/100_concat8.in ${PRODDIR}
cd $PRODDIR
sed -i 's/TEMP/300/g' prod.in

echo "running for 20ns, four trajectories"
sed -i "s/100000000/12500000/g" prod.in
pmemd.cuda -O -i $PRODDIR/prod.in \
    -o $PRODDIR/prod5.out \
    -p ${MINDIR}/protlig-solv.prmtop  \
    -c $PRODDIR/prod4.rst \
    -r $PRODDIR/prod5.rst \
    -x $PRODDIR/prod5.nc \
    -ref ${MINDIR}/protlig-solv.inpcrd
echo "running second trajectory"
pmemd.cuda -O -i $PRODDIR/prod.in \
    -o $PRODDIR/prod6.out \
    -p ${MINDIR}/protlig-solv.prmtop  \
    -c $PRODDIR/prod5.rst \
    -r $PRODDIR/prod6.rst \
    -x $PRODDIR/prod6.nc \
    -ref ${MINDIR}/protlig-solv.inpcrd
echo "running third trajectory"
pmemd.cuda -O -i $PRODDIR/prod.in \
    -o $PRODDIR/prod7.out \
    -p ${MINDIR}/protlig-solv.prmtop  \
    -c $PRODDIR/prod6.rst \
    -r $PRODDIR/prod7.rst \
    -x $PRODDIR/prod7.nc \
    -ref ${MINDIR}/protlig-solv.inpcrd
echo "running 4th and final trajectory"
pmemd.cuda -O -i $PRODDIR/prod.in \
    -o $PRODDIR/prod8.out \
    -p ${MINDIR}/protlig-solv.prmtop  \
    -c $PRODDIR/prod7.rst \
    -r $PRODDIR/prod8.rst \
    -x $PRODDIR/prod8.nc \
    -ref ${MINDIR}/protlig-solv.inpcrd
cp ${PROTOCOL}/cpptraj_inputs/100_concat8.in ./

cpptraj -i 100_concat8.in
