#!/usr/bin/env sh
#$ -cwd
#$ -j y

SGE_TASK_ID=2700

MASTER_PATH=/u/home/r/ruthjohn/ruthjohn/unity_v3.0
SCRIPT_DIR=${MASTER_PATH}/scripts
SRC_DIR=${MASTER_PATH}/src
SIM_DIR=${MASTER_PATH}/misc
SIM_RESULTS_DIR=${MASTER_PATH}/misc

PREFIX_PATH=${MASTER_PATH}/misc/prefix_h2.txt
UKBB_LD=${MASTER_PATH}/misc/ukbb.500.ld
UKBB_HALF=${MASTER_PATH}/misc/ukbb.500.half_ld.npy
NO_LD=${MASTER_PATH}/misc/ukbb.500.identity

source /u/local/Modules/default/init/modules.sh
module load python/2.7

while read line
do

  P_SIM=$(echo $line | cut -d' ' -f1)
  H2=$(echo $line | cut -d' ' -f2)
  N=$(echo $line | cut -d' ' -f3)
  LD=$(echo $line | cut -d' ' -f4)
  M_GW=500000

  for i in {1..100}
  do
      COUNTER=$((COUNTER+1))
      if [[ $COUNTER -eq $SGE_TASK_ID ]]
      then

        echo "p_"${P_SIM}"_h2_"${H2}"_N_"${N}"_ld"_${LD}"_"${i}

        PREFIX="p_"${P_SIM}"_h2_"${H2}"_N_"${N}"_ld"_${LD}
        GWAS_FILE=${SIM_DIR}/$PREFIX"_"${i}.gwas

      	if [ "$LD" -eq "1" ]
      	then
      	    LD_FILE=$UKBB_LD
      	    LD_HALF_FILE=$UKBB_HALF
      	elif [ "$LD" -eq "0" ]
      	then
      	    LD_FILE=$NO_LD
      	    LD_HALF_FILE=$NO_LD
      	else
      	    echo "User argument for LD invalid...exiting"
      	    exit 1
      	fi

      	  #python ${SCRIPT_DIR}/transform_betas.py --gwas_file $GWAS_FILE --ld_file $LD_FILE

      	  ITS=1000
      	  python ${SRC_DIR}/main_new.py \
	    --seed $i \
            --N $N \
            --id $PREFIX \
            --its $ITS \
            --ld_half_file $LD_HALF_FILE \
            --gwas_file $GWAS_FILE  \
            --outdir $SIM_RESULTS_DIR \
	    --H_gw $H2 \
            --M_gw $M_GW \
	    --dp

        fi
  done
done < $PREFIX_PATH
