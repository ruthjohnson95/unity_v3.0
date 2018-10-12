#!/usr/bin/env sh 
#$ -cwd
#$ -j y
#$ -l h_data=5G,h_rt=5:00:00,highp
#$ -o unity_v3_sims.log
#$ -t 1-100:1

SGE_TASK_ID=1

#source /u/local/Modules/default/init/modules.sh
#module load python/2.7

for i in {1..100}
do
    COUNTER=$((COUNTER+1))
    if [[ $COUNTER -eq $SGE_TASK_ID ]]
    then

	sim_yaml=$1

        # parse simulation parameters from input file 
	SIM_NAME="Whole_Blood"
	N=338
	P_SIM=0.05
	#OUTDIR=/u/home/r/ruthjohn/ruthjohn/unity_v3.0/results
	OUTDIR=/Users/ruthiejohnson/Development/unity_v3.0/results
	SEED=$SGE_TASK_ID

	LD_FILE=/Users/ruthiejohnson/Development/unity_v3.0/misc/GTEx_sample/GTEx.Whole_Blood.ENSG00000024862.12.CCDC28A.ld.filter 
	
	LD_HALF_FILE=/Users/ruthiejohnson/Development/unity_v3.0/misc/GTEx_sample/GTEx.Whole_Blood.ENSG00000024862.12.CCDC28A.half_ld.filter

	python scripts/half_ld.py --ld_file $LD_FILE  --ld_out $LD_HALF_FILE

	GWAS_FILE=/Users/ruthiejohnson/Development/unity_v3.0/misc/GTEx_sample/GTEx.Whole_Blood.ENSG00000024862.12.CCDC28A.locus.filter 

	# transform betas 
	python scripts/transform_betas.py --gwas_file $GWAS_FILE --ld_file $LD_FILE


	OUTDIR=${OUTDIR}/${SIM_NAME}
	mkdir -p $OUTDIR


	ITS=10000
	python src/unity_v3_block.py --seed $SEED  --N $N --id $SIM_NAME --its $ITS --ld_half_file $LD_HALF_FILE --gwas_file $GWAS_FILE  --outdir $OUTDIR --non_inf_var 'n' --dp 'y' --full 'y' 

      fi 
done 