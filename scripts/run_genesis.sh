#!/usr/bin/env sh
#$ -cwd
#$ -j y
#$ -l h_data=5G,h_rt=2:00:00,highp
#$ -o run_genesis.log
#$ -t 1-2700:1

MASTER_PATH=/u/home/r/ruthjohn/ruthjohn/unity_v3.0
SCRIPT_DIR=${MASTER_PATH}/scripts
SIM_DIR=${MASTER_PATH}/sims_10K_h2
SIM_RESULTS_DIR=${MASTER_PATH}/sim_results_10K_h2

PREFIX_PATH=${MASTER_PATH}/misc/prefix_h2.txt

#SGE_TASK_ID=1

source /u/local/Modules/default/init/modules.sh
module load R/3.5.1

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

        echo "p_sim_"${P_SIM}"_sigG_"${SIGMA_G}"_N_"${N}"_"${i}

	PREFIX="p_"${P_SIM}"_h2_"${SIGMA_G}"_N_"${N}"_ld"_${LD}
        GWAS_FILE=${SIM_DIR}/$PREFIX"_"${i}.gwas

	outfile="p_"${P_SIM}"_h2_"${SIGMA_G}"_N_"${N}"_ld_"${LD}.${i}.genesis.log
        
	Rscript $SCRIPT_DIR/genesis.R \
          --gwas_file $GWAS_FILE  > $SIM_RESULTS_DIR/$outfile

	sleep 300

      fi
  done
done < $PREFIX_PATH
