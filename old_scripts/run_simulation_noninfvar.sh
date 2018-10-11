#!/usr/bin/env sh 
#$ -cwd
#$ -j y
#$ -l h_data=5G,h_rt=5:00:00,highp
#$ -o N300_noninfvar.log
#$ -t 1-1:1

SGE_TASK_ID=1

source /u/local/Modules/default/init/modules.sh
module load python/2.7

for i in {1..100}
do
    COUNTER=$((COUNTER+1))
    if [[ $COUNTER -eq $SGE_TASK_ID ]]
#    if [[ $COUNTER -eq $COUNTER ]]
    then

	sim_yaml=$1

        # parse simulation parameters from input file 
	SIM_NAME=$(cat $sim_yaml | grep "SIM NAME" | cut -d':' -f2 | tr -d " \t\n\r" )
	H_GWAS=$(cat $sim_yaml | grep "H GWAS" | cut -d':' -f2 | tr -d " \t\n\r" )
	H_SNP=$(cat $sim_yaml | grep "H SNP" | cut -d':' -f2 | tr -d " \t\n\r" )
	P_SIM=$(cat $sim_yaml | grep "P SIM" | cut -d':' -f2 | tr -d " \t\n\r" )
	N=$(cat $sim_yaml | grep "SAMPLE SIZE" | cut -d':' -f2 | tr -d " \t\n\r" )
	OUTDIR=$(cat $sim_yaml | grep "OUTDIR" | cut -d':' -f2 | tr -d " \t\n\r" )
	LD_FILE=$(cat $sim_yaml | grep "LD FILE" | cut -d':' -f2 | tr -d " \t\n\r" )
	SEED=$COUNTER

        # make simulation dir 
	OUTDIR=${OUTDIR}/${SIM_NAME}
	mkdir -p $OUTDIR

        # generate sample gwas 
	python scripts/simulate.py --sim_name $SIM_NAME --h_snp $H_SNP --h_gwas $H_GWAS --p_sim $P_SIM --N $N  --seed $SEED --ld_file $LD_FILE --outdir $OUTDIR

        # transform betas 
	GWAS_FILE=${OUTDIR}/chr$SEED.0.0.gwas
	python scripts/transform_betas.py --gwas_file $GWAS_FILE --ld_file $LD_FILE

        # take 1/2 power of ld 
	LD_BASE_FILE=$(basename $LD_FILE) 
	LD_PREFIX=${LD_BASE_FILE%.*}
	LD_HALF_FILE=${OUTDIR}/${LD_PREFIX}.half_ld

	python scripts/half_ld.py --ld_file $LD_FILE  --ld_out $LD_HALF_FILE
	
        # run inference 
	ITS=10000
	python src/unity_v3_block.py --seed $SEED --H_snp $H_SNP  --H_gwas $H_GWAS  --N $N --id $SIM_NAME --its $ITS --ld_half_file $LD_HALF_FILE --gwas_file $GWAS_FILE  --outdir $OUTDIR --non_inf_var 'y' --dp 'n'  

      fi 
done 