#!/usr/bin/env sh
#$ -cwd
#$ -j y
#$ -l h_data=2G,h_rt=30:00:00,highp
#$ -o run_genesis.log
#$ -t 1-900:1

MASTER_PATH=/u/home/r/ruthjohn/ruthjohn/unity_v3.0
SCRIPT_DIR=${MASTER_PATH}/scripts
SIM_DIR=${MASTER_PATH}/sims_6K
SIM_RESULTS_DIR=${MASTER_PATH}/sim_results_6K_genesis

PREFIX_PATH=${MASTER_PATH}/misc/prefix.txt

#SGE_TASK_ID=2

source /u/local/Modules/default/init/modules.sh
module load R/3.5.1

while read line
do

  P_SIM=$(echo $line | cut -d' ' -f1)
  SIGMA_G=$(echo $line | cut -d' ' -f2)
  N=$(echo $line | cut -d' ' -f3)

  for i in {1..100}
  do
#      COUNTER=$((COUNTER+1))
#      if [[ $COUNTER -eq $SGE_TASK_ID ]]
#      then

        echo "p_sim_"${P_SIM}"_sigG_"${SIGMA_G}"_N_"${N}"_"${i}

        Rscript $SCRIPT_DIR/genesis.R \
          --sigG $SIGMA_G \
          --p_sim $P_SIM \
          --N $N \
          --outdir $SIM_RESULTS_DIR \
          --seed $i \
          --gwas_dir $SIM_DIR

#      fi
  done
done < $PREFIX_PATH
