#!/usr/bin/env sh
#$ -cwd
#$ -j y
#$ -l h_data=25G,h_rt=6:00:00,highp
#$ -o test_full_varyH.log
#$ -t 1-5400:1

#SGE_TASK_ID=1

MASTER_PATH=/u/home/r/ruthjohn/ruthjohn/unity_v3.0
SCRIPT_DIR=${MASTER_PATH}/scripts
SRC_DIR=${MASTER_PATH}/src
SIM_DIR=${MASTER_PATH}/sims_10K
SIM_RESULTS_DIR=${MASTER_PATH}/sim_results_full_varyH

PREFIX_PATH=${MASTER_PATH}/misc/prefix.txt
UKBB_LD=${MASTER_PATH}/misc/chr22.0.0.ld.npy
UKBB_HALF=${MASTER_PATH}/misc/chr22.0.0.half_ld.npy
NO_LD=${MASTER_PATH}/misc/chr22.0.0.identity

source /u/local/Modules/default/init/modules.sh
module load python/2.7

while read line
do

  P_SIM=$(echo $line | cut -d' ' -f1)
  SIGMA_G=$(echo $line | cut -d' ' -f2)
  N=$(echo $line | cut -d' ' -f3)
  LD=$(echo $line | cut -d' ' -f4)

  for i in {1..100}
  do
      COUNTER=$((COUNTER+1))
      if [[ $COUNTER -eq $SGE_TASK_ID ]]
      then

        echo "p_"${P_SIM}"_sigG_"${SIGMA_G}"_N_"${N}"_ld"_${LD}"_"${i}

        PREFIX="p_"${P_SIM}"_sigG_"${SIGMA_G}"_N_"${N}"_ld"_${LD}
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
	
        # transform betas
#    	  python ${SCRIPT_DIR}/transform_betas.py --gwas_file $GWAS_FILE --ld_file $LD_FILE

    	  ITS=250
    	  python ${SRC_DIR}/main.py \
          --seed $i \
          --N $N \
          --id $PREFIX \
          --its $ITS \
          --ld_half_file $LD_HALF_FILE \
          --gwas_file $GWAS_FILE  \
          --outdir $SIM_RESULTS_DIR \
          --dp 'y' \
          --full 'y' 

      fi
  done
done < $PREFIX_PATH
