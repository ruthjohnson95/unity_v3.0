#!/usr/bin/env sh 
#$ -cwd
#$ -j y
#$ -l h_data=64G,h_rt=72:00:00,highp
#$ -o ukbb_block_height_noHLA_chr1_2.log
#$ -t 1-2:1

# There are 58 files

#SGE_TASK_ID=2

source /u/local/Modules/default/init/modules.sh
module load python/2.7
module load R 

# assumes all of the preprocessing files are made 
TRAIT=height
GWAS_DIR=/u/flashscratch/r/ruthjohn/ukbb_${TRAIT}_exp/gwas_noHLA
OUTDIR=/u/flashscratch/r/ruthjohn/ukbb_${TRAIT}_exp/results_noHLA
mkdir -p ${OUTDIR}

N=337205
ITS=100
SEED=2018

# global paths 
SCRIPT_DIR=/u/flashscratch/r/ruthjohn/ukbb_${TRAIT}_exp/scripts
SRC_DIR=/u/flashscratch/r/ruthjohn/ukbb_${TRAIT}_exp/src

for file in `ls -v $GWAS_DIR/*.clean.snplist`
do

    COUNTER=$((COUNTER+1))

    if [[ $COUNTER -eq $SGE_TASK_ID ]]
    then

	echo $file 

	PREFIX=$(basename $file | cut -d'.' -f1,2,3) #chr.bp.bp
	GWAS_LOCI=${GWAS_DIR}/${PREFIX}.loci.clean

	SIM_NAME=${PREFIX}
	LD_FILE=${GWAS_DIR}/${PREFIX}.ld 
	LD_HALF_FILE=${GWAS_DIR}/${PREFIX}.half_ld

	python $SRC_DIR/unity_v3_block.py --seed $SEED  --N $N --id $SIM_NAME --its $ITS --ld_half_file $LD_HALF_FILE --gwas_file $GWAS_LOCI  --outdir $OUTDIR  --dp 'y' --full 'y' 

fi

done