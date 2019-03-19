#!/usr/bin/env sh
#$ -cwd
#$ -j y
#$ -l h_data=10G,h_rt=6:00:00,highp
#$ -o run_inference_varyM.log
#$ -t 100-400:1

SGE_TASK_ID=77

MASTER_PATH=/u/home/r/ruthjohn/ruthjohn/unity_v3.0
SCRIPT_DIR=${MASTER_PATH}/scripts
SRC_DIR=${MASTER_PATH}/src_cp
SIM_DIR=${MASTER_PATH}/sims_varyM
SIM_RESULTS_DIR=${MASTER_PATH}/sim_results_varyM
mkdir -p $SIM_RESULTS_DIR
PREFIX_PATH=${MASTER_PATH}/misc/prefix_varyM.txt

source /u/local/Modules/default/init/modules.sh
module load python/2.7

while read line
do

  P_SIM=$(echo $line | cut -d' ' -f1)
  H2=$(echo $line | cut -d' ' -f2 | awk ' sub("\\.*0+$","") ')
  N=$(echo $line | cut -d' ' -f3)
  LD=$(echo $line | cut -d' ' -f4)
  M=$(echo $line | cut -d' ' -f5)
  M_GW=500000

  for i in {1..100}
  do
      COUNTER=$((COUNTER+1))
      if [[ $COUNTER -eq $SGE_TASK_ID ]]
      then

	echo "p_sim_"${P_SIM}"_h2_"${H2}"_N_"${N}"_ld_"${LD}"_M_"${M}"_"${SGE_TASK_ID}

        PREFIX="p_"${P_SIM}"_h2_"${H2}"_N_"${N}"_ld"_${LD}"_M_"${M}
        GWAS_FILE=${SIM_DIR}/$PREFIX"_"${i}.gwas

	# get correct LD file based on M
	LD_FILE=${MASTER_PATH}/misc/ukbb.${M}.ld.npy
	LD_HALF_FILE=${MASTER_PATH}/misc/ukbb.${M}.ld.neg_half_ld.npy

          # transform betas
      	  #python ${SCRIPT_DIR}/transform_betas.py --gwas_file $GWAS_FILE --ld_file $LD_FILE

      	  ITS=250
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

            sleep 300
        fi
  done
done < $PREFIX_PATH
