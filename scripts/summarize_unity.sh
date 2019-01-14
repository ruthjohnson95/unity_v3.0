#!/usr/bin/env bash

MASTER_PATH=/u/home/r/ruthjohn/ruthjohn/unity_v3.0
SCRIPT_DIR=${MASTER_PATH}/scripts
PREFIX_PATH=${MASTER_PATH}/misc/prefix_short.txt
RESULTS_DIR=${MASTER_PATH}/sim_results_full_varyH

RESULT_FILE=${RESULTS_DIR}/summary_unity_v3_10K_full.txt

VARY_H=1

echo "p p_est sigG sigG_est N ld varyH" > $RESULT_FILE

while read line
do
    P=$(echo $line | cut -d' ' -f1)
    SigG=$(echo $line | cut -d' ' -f2)
    N=$(echo $line | cut -d' ' -f3)
    LD=$(echo $line | cut -d' ' -f4)

    for i in {1..100}
    do

	file=$RESULTS_DIR/p_${P}_sigG_${SigG}_N_${N}_ld_${LD}.${i}.unity_v3.log
	P_EST=$(tail $file | grep "Estimate p:" | cut -d' ' -f3)
	SIG_G_EST=$(tail $file |grep "Estimate sigma_g" | cut -d' ' -f3)

	echo $P $P_EST $SigG $SIG_G_EST $N $LD $VARY_H >> $RESULT_FILE

    done
done < $PREFIX_PATH