#!/usr/bin/env sh

TRAIT=$1
MASTER_PATH=/u/home/r/ruthjohn/ruthjohn/unity_v3.0/h2_poly
SCRIPT_DIR=/u/home/r/ruthjohn/ruthjohn/unity_v3.0/scripts
TRAIT_DIR=${MASTER_PATH}/${TRAIT}
RESULT_DIR=${TRAIT_DIR}/${BLOCK_SIZE}
META_DIR=${MASTER_PATH}/meta_data
SUM_FILE=${TRAIT_DIR}/${TRAIT}.summary.txt
ALL_SUM_FILE=${MASTER_PATH}/ALL.summary.txt

echo "BLOCK CHR START STOP H2 M P_EST P_SD" > $SUM_FILE


for BLOCK_SIZE in 6mb 12mb 24mb 48mb
do
 
    CSV_FILE=${META_DIR}/${TRAIT}.${BLOCK_SIZE}.csv
    echo $CSV_FILE
    for row in `tail -n +2 $CSV_FILE`
#    while read row
    do
#	echo $row
	CHR=$(echo $row | cut -d',' -f2)
	START=$(echo $row |cut -d',' -f3)
	STOP=$(echo $row |cut -d',' -f4)
	H2=$(echo $row |cut -d',' -f9)
	M=$(echo $row |cut -d',' -f5)
	N=$(echo $row |cut -d',' -f6)
	
	PREFIX=chr_${CHR}_start_${START}_stop_${STOP}
	RESULT_FILE=${TRAIT_DIR}/$BLOCK_SIZE/${PREFIX}.*.unity_v3.log
	
	if [ ! -f $RESULT_FILE ]; then
	    P_EST=0
	else
	    P_EST=$(tail $RESULT_FILE | grep "Estimate p:" | cut -d' ' -f3)
	    P_SD=$(tail $RESULT_FILE | grep "SD p:" | cut -d' ' -f3)
	fi
	
#      	echo $P_EST
	echo $BLOCK_SIZE $CHR $START $STOP $H2 $M $P_EST $P_SD >> $SUM_FILE

    done 

done