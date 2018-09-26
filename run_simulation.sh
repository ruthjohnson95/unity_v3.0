#!/usr/bin/env sh 
#$ -cwd
#$ -j y
#$ -l h_data=10G,h_rt=4:00:00,highp
#$ -o unity_v3_sims.log
#$ -t 1-100:1

#SGE_TASK_ID=1

source /u/local/Modules/default/init/modules.sh
module load python/2.7

for i in {1..100}
do
    COUNTER=$((COUNTER+1))
    if [[ $COUNTER -eq $SGE_TASK_ID ]]
    then

	sim_yaml=$1

        # parse simulation parameters from input file 
	SIM_NAME=$(cat $sim_yaml | grep "SIM NAME" | cut -d':' -f2 | tr -d " \t\n\r" )
	H_SIM=$(cat $sim_yaml | grep "HERITABILITY" | cut -d':' -f2 | tr -d " \t\n\r" )
	P_SIM=$(cat $sim_yaml | grep "P SIM" | cut -d':' -f2 | tr -d " \t\n\r" )
	N=$(cat $sim_yaml | grep "SAMPLE SIZE" | cut -d':' -f2 | tr -d " \t\n\r" )
	BLOCKS=$(cat $sim_yaml | grep "BLOCKS" | cut -d':' -f2 | tr -d " \t\n\r" )
	SIM_DIR=$(cat $sim_yaml | grep "SIM DIR" | cut -d':' -f2 | tr -d " \t\n\r" )
	LD_DIR=$(cat $sim_yaml | grep "LD DIR" | cut -d':' -f2 | tr -d " \t\n\r" )
	LD_HALF_DIR=$(cat $sim_yaml | grep "LD HALF DIR" | cut -d':' -f2 | tr -d " \t\n\r" )
	ITS=$(cat $sim_yaml | grep "ITS" | cut -d':' -f2 | tr -d " \t\n\r" )

	SEED=$SGE_TASK_ID

        # make simulation dir 
	OUTDIR=$SIM_DIR'/'$SIM_NAME'_'$SEED 
	mkdir -p $OUTDIR

        # generate sample gwas 
	python scripts/simulate.py --sim_name $SIM_NAME --h_sim $H_SIM --p_sim $P_SIM --N $N --blocks $BLOCKS --seed $SEED --ld_dir $LD_DIR --outdir $OUTDIR

        # transform betas 
	python scripts/transform_betas.py --gwas_dir $OUTDIR --ld_dir $LD_DIR

        # make directory for half ld 
	mkdir -p $LD_HALF_DIR

        # take 1/2 power of ld 
#	python scripts/half_ld.py --ld_dir $LD_DIR --ld_half_dir $LD_HALF_DIR --blocks $BLOCKS

        # run inference 
	python src/unity_v3.py --seed $SEED --H $H_SIM --N $N --id $SIM_NAME --ld_half_dir $LD_HALF_DIR --gwas_dir $OUTDIR --outdir $OUTDIR --its $ITS

      fi 
done 