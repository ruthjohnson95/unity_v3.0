#!/usr/bin/env bash

MASTER_PATH=/u/home/r/ruthjohn/ruthjohn/unity_v3.0
SCRIPT_DIR=${MASTER_PATH}/scripts
PREFIX_PATH=${MASTER_PATH}/misc/prefix.txt
RESULTS_DIR=${MASTER_PATH}/sim_results_10K

RESULT_FILE=${RESULTS_DIR}/summary_genesis_10K.txt

echo "p p_est sigG sigG_est" > $RESULT_FILE

# only look at log files
for file in `ls -v $RESULTS_DIR/*.genesis`
do

    P=$(basename $file | cut -d'_' -f2)
    SigG=$(basename $file | cut -d'_' -f4)

    P_EST=$(cat $file | grep "PIC-est:" | cut -d' ' -f2)
    SIG_G_EST=$(cat $file |grep "sigG-est:" | cut -d' ' -f2)

    echo $P $P_EST $SigG $SIG_G_EST >> $RESULT_FILE

done
