#!/usr/bin/env bash

MASTER_PATH=/u/home/r/ruthjohn/ruthjohn/unity_v3.0
SCRIPT_DIR=${MASTER_PATH}/scripts
PREFIX_PATH=${MASTER_PATH}/misc/prefix_varyM.txt
RESULTS_DIR=${MASTER_PATH}/sim_results_varyM

RESULT_FILE=${RESULTS_DIR}/summary_unity_v3_10K_varyM.txt

echo "p p_est h2 N ld M" > $RESULT_FILE

while read line
do
      P=$(echo $line | cut -d' ' -f1)
      H2=$(echo $line | cut -d' ' -f2 | awk ' sub("\\.*0+$","") ')
      N=$(echo $line | cut -d' ' -f3)
      LD=$(echo $line | cut -d' ' -f4)
      M=$(echo $line | cut -d' ' -f5)

      PREFIX="p_"${P}"_h2_"${H2}"_N_"${N}"_ld"_${LD}"_M_"${M}

      for i in {1..100}
      do

	file=$RESULTS_DIR/$PREFIX.${i}.unity_v3.log
	P_EST=$(tail $file | grep "Estimate p:" | cut -d' ' -f3)
	echo $P $P_EST $H2 $N $LD $M >> $RESULT_FILE

    done
done < $PREFIX_PATH