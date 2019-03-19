#!/usr/bin/env bash

MASTER_PATH=/u/home/r/ruthjohn/ruthjohn/unity_v3.0
SCRIPT_DIR=${MASTER_PATH}/scripts
PREFIX_PATH=${MASTER_PATH}/misc/prefix_kk.txt
RESULTS_DIR=${MASTER_PATH}/sim_results_kk

RESULT_FILE=${RESULTS_DIR}/summary_unity_v3_10K_kk.txt

VARY_H=1

echo "p p_est h2 N maf ld maf_low maf_high" > $RESULT_FILE

while read line
do
    CAU_RATIO=$(echo $line | cut -d' ' -f1)
    HSQ=$(echo $line | cut -d' ' -f2)
    MAF=$(echo $line | cut -d' ' -f3)
    ld=$(echo $line | cut -d' ' -f4)
    MAF_LOW=$(echo $line | cut -d' ' -f5)
    MAF_HIGH=$(echo $line | cut -d' ' -f6)

    H2=$HSQ
    LD=1
    N=337205
    M_GW=9564
    P=$CAU_RATIO

    PREFIX=cau_ratio_${CAU_RATIO}_hsq_${HSQ}_maf_${MAF}_ld_${ld}_range_${MAF_LOW}_${MAF_HIGH}

    for i in {1..100}
    do

	file=$RESULTS_DIR/$PREFIX.${i}.unity_v3.log
	P_EST=$(tail $file | grep "Estimate p:" | cut -d' ' -f3)
#	SIG_G_EST=$(tail $file |grep "Estimate sigma_g" | cut -d' ' -f3)
#	echo $P $P_EST $SigG $SIG_G_EST $N $LD $VARY_H >> $RESULT_FILE
	echo $P $P_EST $H2 $N $ld $MAF $MAF_LOW $MAF_HIGH>> $RESULT_FILE
    done
done < $PREFIX_PATH