#!/usr/bin/env sh 
#$ -cwd
#$ -j y
#$ -l h_data=5G,h_rt=5:00:00,highp
#$ -o unity_v3_sims.log
#$ -t 1-100:1

SGE_TASK_ID=1

source /u/local/Modules/default/init/modules.sh
module load python/2.7

for i in {1..100}
do
    COUNTER=$((COUNTER+1))
    if [[ $COUNTER -eq $SGE_TASK_ID ]]
    then

	sim_yaml=$1

        # parse simulation parameters from input file 
	SIM_NAME="test_model"
	SIGMA_G=0.01
	SIGMA_E=9.499999999999999e-06
	N=100000
	P_SIM=0.01
	OUTDIR=/u/home/r/ruthjohn/ruthjohn/unity_v3.0/results
	SEED=$SGE_TASK_ID
	# use identity LD 
	LD_FILE=/u/home/r/ruthjohn/ruthjohn/unity_v3.0/misc/identity_372.ld

        # make simulation dir 
	OUTDIR=${OUTDIR}/${SIM_NAME}
	mkdir -p $OUTDIR

        # generate sample gwas 
	python scripts/simulate_full.py --sim_name $SIM_NAME --h_snp $H_SNP --h_gwas $H_GWAS --p_sim $P_SIM --N $N  --seed $SEED --ld_file $LD_FILE --outdir $OUTDIR

        # transform betas 
	GWAS_FILE=${OUTDIR}/chr$SEED.0.0.gwas
	python scripts/transform_betas.py --gwas_file $GWAS_FILE --ld_file $LD_FILE

        # take 1/2 power of ld 
	LD_BASE_FILE=$(basename $LD_FILE) 
	LD_PREFIX=${LD_BASE_FILE%.*}
	LD_HALF_FILE=${OUTDIR}/${LD_PREFIX}.half_ld
	python scripts/half_ld.py --ld_file $LD_FILE  --ld_out $LD_HALF_FILE
	
        # run inference 
	ITS=20
	python src/unity_v3_block.py --seed $SEED  --N $N --id $SIM_NAME --its $ITS --ld_half_file $LD_HALF_FILE --gwas_file $GWAS_FILE  --outdir $OUTDIR --non_inf_var 'n' --dp 'y' --full 'y' 

      fi 
done 