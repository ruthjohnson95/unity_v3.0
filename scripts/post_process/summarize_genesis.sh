#!/usr/bin/env bash

MASTER_PATH=/u/home/r/ruthjohn/ruthjohn/unity_v3.0
SCRIPT_DIR=${MASTER_PATH}/scripts
PREFIX_PATH=${MASTER_PATH}/misc/prefix_h2.txt
RESULTS_DIR=${MASTER_PATH}/sim_results_10K_h2

RESULT_FILE=${RESULTS_DIR}/summary_genesis_10K.txt

VARY_H=1

echo "p p_est h2 SigG_est N ld varyH" > $RESULT_FILE

while read line
do
    P=$(echo $line | cut -d' ' -f1)
    SigG=$(echo $line | cut -d' ' -f2)
    N=$(echo $line | cut -d' ' -f3)
    LD=$(echo $line | cut -d' ' -f4)

    for i in {1..100}
    do

    	file=$RESULTS_DIR/p_${P}_h2_${SigG}_N_${N}_ld_${LD}.${i}.genesis.log
      P_EST=$(cat $file | grep "PIC-est:" | cut -d' ' -f2)
      SIG_G_EST=$(cat $file |grep "sigG-est:" | cut -d' ' -f2)

    	echo $P $P_EST $SigG $SIG_G_EST $N $LD $VARY_H >> $RESULT_FILE

    done
done < $PREFIX_PATH
