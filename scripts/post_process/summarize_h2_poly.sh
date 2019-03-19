#!/usr/bin/env bash

BLOCK_SIZE=berisa
RESULTS_DIR=/u/home/r/ruthjohn/ruthjohn/unity_v3.0/h2_poly/height/${BLOCK_SIZE}
RESULT_FILE=${RESULTS_DIR}/summary_h2_poly.txt
CSV_FILE=${RESULTS_DIR}/height.${BLOCK_SIZE}.csv

echo "CHR START STOP H2 M P_EST" > $RESULT_FILE

i=1
while read row
do
    test $i -eq 1 && ((i=i+1)) && continue

    CHR=$(echo $row | cut -d',' -f1)
    START=$(echo $row |cut -d',' -f2)
    STOP=$(echo $row |cut -d',' -f3)
    H2=$(echo $row |cut -d',' -f11)
    M=$(echo $row |cut -d',' -f5)

    PREFIX=chr_${CHR}_start_${START}_stop_${STOP}

    file=${RESULTS_DIR}/${PREFIX}.*.unity_v3.log
    P_EST=$(tail $file | grep "Estimate p:" | cut -d' ' -f3)

    echo $CHR $START $STOP $H2 $M $P_EST  >> $RESULT_FILE

done < $CSV_FILE