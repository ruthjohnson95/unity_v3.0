#!/usr/bin/env sh 
#$ -cwd
#$ -j y
#$ -l h_data=40G,h_rt=24:00:00,highp
#$ -o ukbb_block_height_chr_unity.log
#$ -t 1-22:1

#SGE_TASK_ID=22

source /u/local/Modules/default/init/modules.sh
module load python/2.7
module load R 

# assumes all of the preprocessing files are made 

MAIN_DIR=/u/flashscratch/r/ruthjohn/ukbb_height_exp
SNP_DIR=${MAIN_DIR}/gwas/snplists_chr
PLINK=/u/home/r/ruthjohn/pasaniucdata/software/plink

for file in `ls $SNP_DIR/*.snplists`
do

    COUNTER=$((COUNTER+1))

    if [[ $COUNTER -eq $SGE_TASK_ID ]]
    then


CHR=$(echo $file | cut -d'.' -f1 | sed 's/[^0-9]*//g')

GWAS_DIR=${MAIN_DIR}/gwas
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

SCRIPT_DIR=${MAIN_DIR}/scripts
SRC_DIR=${MAIN_DIR}/src

SIM_NAME=${PREFIX}
N=337205

ITS=100
SEED=2018

LD_FILE=${OUTDIR}/${PREFIX}.ld 
LD_HALF_FILE=${OUTDIR}/${PREFIX}.half_ld


GWAS_LOCI=$GWAS_LOCI.clean

OUTDIR=${MAIN_DIR}/results_chr_long
mkdir -p $OUTDIR


python $SRC_DIR/unity_v3_block.py --seed $SEED  --N $N --id $SIM_NAME --its $ITS --ld_half_file $LD_HALF_FILE --gwas_file $GWAS_LOCI  --outdir $OUTDIR  --dp 'y' --full 'y' 

fi

done