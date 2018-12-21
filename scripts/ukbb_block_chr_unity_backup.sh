#!/usr/bin/env sh 
#$ -cwd
#$ -j y
#$ -l h_data=20G,h_rt=24:00:00,highp
#$ -o ukbb_block_height_noHLA.log
#$ -t 1-22:1

# There are 58 files

SGE_TASK_ID=22

source /u/local/Modules/default/init/modules.sh
module load python/2.7
module load R 

# assumes all of the preprocessing files are made 
TRAIT=height
SNP_DIR=/u/flashscratch/r/ruthjohn/ukbb_${TRAIT}_exp/gwas/snplists_noHLA

for file in `ls -v $SNP_DIR/*.snplists`
do

    COUNTER=$((COUNTER+1))

    if [[ $COUNTER -eq $SGE_TASK_ID ]]
    then

	echo $file 

CHR=$(echo $file | cut -d'.' -f1 | sed 's/[^0-9]*//g')
CHR_N=$(echo $file | cut -d'.' -f1 | sed 's/[^0-9]*//')

GWAS_DIR=/u/flashscratch/r/ruthjohn/ukbb_${TRAIT}_exp/gwas

RSID_FILE=${GWAS_DIR}/assoc_chr${CHR}.assoc.linear.snplist
GWAS=${GWAS_DIR}/assoc_chr${CHR}.assoc.linear

file=$(basename $file)
RSID_FILE=$SNP_DIR/$file
OUTDIR=${GWAS_DIR}
PREFIX=$(basename $RSID_FILE | cut -d'.' -f1,2,3) #chr.bp.bp
GWAS_LOCI=${OUTDIR}/${PREFIX}.loci

# start with list of SNPs 
file=$(basename $file)
RSID_FILE=$SNP_DIR/$file

OUTDIR=${GWAS_DIR}
PREFIX=$(basename $RSID_FILE | cut -d'.' -f1,2,3) #chr.bp.bp 
RSID_FILE_CLEAN=${OUTDIR}/${PREFIX}.clean

SCRIPT_DIR=/u/flashscratch/r/ruthjohn/ukbb_${TRAIT}_exp/scripts
SRC_DIR=/u/flashscratch/r/ruthjohn/ukbb_${TRAIT}_exp/src

SIM_NAME=${PREFIX}
N=337205

ITS=100
SEED=2018

LD_FILE=${OUTDIR}/${PREFIX}.ld 
LD_HALF_FILE=${OUTDIR}/${PREFIX}.half_ld

GWAS_LOCI=$GWAS_LOCI.clean

OUTDIR=/u/flashscratch/r/ruthjohn/ukbb_${TRAIT}_exp/results_noHLA
mkdir -p $OUTDIR

python $SRC_DIR/unity_v3_block.py --seed $SEED  --N $N --id $SIM_NAME --its $ITS --ld_half_file $LD_HALF_FILE --gwas_file $GWAS_LOCI  --outdir $OUTDIR  --dp 'y' --full 'y' 

fi

done